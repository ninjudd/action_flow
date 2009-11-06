require 'flow/helper'
require 'flow/context'

module Flow 

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def flow(name)
      helper Flow::Helper

      flow = "#{name}_flow_context".camelize.constantize

      meta_eval do
        define_method(:context) do
          @context ||= flow.find_or_create(params.delete(:_fk))
        end
        private :context
      end

      flow.states.each do |state|
        meta_def(state) do
          context.at_state(state)
          # copy data into instance variables so it can be referenced by views
          context.data.each do |key, value|
            instance_variable_set("@#{key}", value)
          end
        end
      end

      meta_def(:next) do
        context.at_state(params.delete(:state))
        context.fire_transition(self)
        redirect_to(:action => context.state, :_fk => context.key)
      end
    end

  end # module ClassMethods

end # module Flow
