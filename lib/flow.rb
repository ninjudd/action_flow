require 'meta'

module Flow 
  def flow(name)
    flow = "#{name}_flow_context".camelize.constantize

    define_method(:context) do
      @context ||= flow.find_or_create(params[:k])
    end

    flow.states.each do |state|
      define_method(state) do
        context.at(state)
        context.data.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end

    define_method(:next) do
      context.fire_transition(params)
      redirect_to(:action => context.state, :k => context.key)
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
      flow = find_by_key(key) if key
      flow || create(
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
      if states.include?(state)
        @state = state
        states.slice!(0..states.index(state))
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
