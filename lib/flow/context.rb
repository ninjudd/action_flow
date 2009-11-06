require 'flow/core_ext'

module Flow

  class Context < ActiveRecord::Base
    set_table_name 'flow_contexts'
    partial_updates = false

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

    def self.find_or_create(key=nil)
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

    # Class macro used to define a state.
    def self.state(state, &block)
      transitions[state] = block
    end

    # Used within a state definition to fire a transaction
    def transition(state)
      @state = state
      states << state
      save!
      throw :TransitionFired
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

    def at_state(state)
      state = state.to_sym
      if states.include?(state)
        @state = state
        states.slice!((states.index(state) + 1) .. -1)
      else
        raise InvalidState, "state #{state} not valid in this context"
      end
    end

    def state
      @state ||= states.last
    end

    def data
      state_data[state] ||= {}
    end

    attr_reader :controller
    delegate :params, :flash, :to => :controller

    def fire_transition(controller)
      @controller = controller
      catch :TransitionFired do
        transition = self.class.transition(state)
        transition.bind(self).call if transition
      end
    end

    class InvalidState    < StandardError; end

  private

    def self.transitions
      @transitions ||= {}
    end

  end # class Context
end # module Flow
