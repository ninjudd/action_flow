require 'meta'
require 'active_record'
require 'action_controller'

module ActionFlow
  def flow(name)
    helper ActionFlow::Helper

    flow = "#{name}_flow_context".camelize.constantize

    define_method(:context) do
      @context ||= flow.find_or_create(params.delete(:k))
    end
    private :context

    flow.states.each do |state|
      define_method(state) do
        context.at_state(state)
        context.data.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end

    define_method(:next) do
      context.at_state(params.delete(:state))
      context.fire_transition(self)
      redirect_to(:action => context.state, :k => context.key)
    end
  end

  module Helper
    def flow_link_to(name, options = {}, html_options = {})
      options.merge!(flow_options)
      html_options.merge!(:post => true)
      link_to(name, options, html_options)
    end

    def flow_form_tag(options = {}, html_options = {}, *args, &block)
      options.merge!(flow_options)
      html_options.merge!(:method => :post)
      form_tag(options, html_options, *args, &block)
    end

  private

    def flow_options
      {:controller => controller.controller_name, :action => :next, :state => controller.context.state, :k => controller.context.key}
    end
  end

  class Context < ActiveRecord::Base
    set_table_name 'flow_contexts'

    def before_save
      self.states     = Marshal.dump(states)
      self.state_data = Marshal.dump(state_data)
    end

    def after_save
      self.states     = Marshal.load(states)
      self.state_data = Marshal.load(state_data)
    end

    def after_find
      after_save
    end

    inheritable_class_attr :initial
    initial :start

    def self.find_or_create(key = nil)
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
      sha.update(String(rand))
      sha.update(String($$))
      sha.update('go with the flow')
      sha.hexdigest
    end

    def self.transitions
      @transitions ||= {}
    end

    def self.transition(state)
      ancestors.each do |klass|
        return if klass == ActionFlow::Context
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

    attr_reader :controller
    delegate :params, :flash, :to => :controller

    def at_state(state)
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

    def fire_transition(controller)
      @controller = controller
      begin
        transition = self.class.transition(state)
        transition.bind(self).call
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

class ActionController::Base
  extend ActionFlow
end
