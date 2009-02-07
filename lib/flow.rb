require 'meta'

module Flow 
  def flow(name)
    helper Flow::Helper

    flow = "#{name}_flow_context".camelize.constantize

    define_method(:context) do
      @context ||= flow.find_or_create(params.delete(:k))
    end
    private :context

    flow.states.each do |state|
      define_method(state) do
        context.at(state)
        context.data.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end

    define_method(:next) do
      context.at(params.delete(:state))
      context.fire_transition(params)
      redirect_to(:action => context.state, :k => context.key)
    end
  end
  
  module Helper
    def flow_link_to(name, options = {}, html_options = {})
      options.merge!(flow_options)
      html_options.merge!(:post => true)
      link_to(name, options)
    end
    
    def flow_form_tag(options = {}, html_options = {}, *args, &block)
      options.merge!(flow_options)
      html_options.merge!(:method => :post)
      form_tag(options, html_options, *args, &block)
    end

  private
    
    def flow_options
      {:controller => controller.controller_name, :action => :next, :state => @context.state, :k => @context.key}
    end
  end

  class Context < ActiveRecord::Base
    set_table_name 'flow_contexts'

    serialize :states, Array
    serialize :state_data, Hash
    self.partial_updates = false

    inheritable_class_attr :initial
    initial :start

    def self.find_or_create(key)
      context = find_by_key(key) if key
      context || create(
        :states     => [initial],
        :state_data => {},
        :key        => generate_key
      )
    end

    def self.generate_key
      sha = Digest::SHA1::new
      now = Time.now
      sha.update(now.to_s)
      sha.update(String(now.usec))
      sha.update(String(rand(0)))
      sha.update(String($$))
      sha.update('go with the flow')
      sha.hexdigest
    end

    def self.transitions
      @transitions ||= {}
    end

    def self.transition(state)
      ancestors.each do |klass|
        return if klass == Flow::Context
        next unless klass.respond_to?(:transitions)
        transition = klass.transitions[state]
        return transition if transition
      end
    end
        
    def self.states
      transitions.keys
    end

    def self.state(state, &block)
      transitions[state] = block
    end

    def at(state)
      state = state.to_sym
      if states.include?(state)
        @state = state
        states.slice!(states.index(state) + 1..-1)
      else
        raise InvalidState, "state #{state} not valid in this context"
      end
    end

    def state
      @state ||= states.last
    end

    def data
      state_data[:state] ||= {}
    end

    def fire_transition(params)
      begin
        transition = self.class.transition(state)
        transition.bind(self).call(params)
      rescue TransitionFired
      end
    end

    def transition(state)
      @state = state
      self.states << state
      self.save
      raise TransitionFired
    end

    class InvalidState    < StandardError; end
    class TransitionFired < Exception;     end
  end
end
