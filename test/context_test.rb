require File.expand_path(File.dirname(__FILE__) + '/test_helper')

ENV['DB'] = 'postgres'

require 'lib/activerecord_test_case'
require 'flow/context'


module Flow

  class ContextTest < ActiveRecordTestCase

    class ParentContext < Flow::Context

      state :start do
        transition(:parent_one)
      end

      state :parent_one do
        transition(:parent_two)
      end

      state :parent_two

    end

    class ChildContext < ParentContext

      state :parent_two do
        transition(:child_one)
      end

      state :child_one do
        transition(:child_two)
      end

      state :child_two

    end
    
    def test_find_or_create
      assert_difference 'Flow::Context.count' do
        ChildContext.find_or_create
      end
    end

    def test_state_serializaton
      ChildContext.find_or_create
      assert_equal [:start], ChildContext.first.states
    end

    def test_state_data_serializaton
      state_data = {:one=>1, :two=>2, (1..10)=>'1 to 10'}
      ChildContext.find_or_create.update_attributes(:state_data=>state_data)
      assert_equal state_data, ChildContext.first.state_data
    end
    
    def test_singleton_transition_for_valid_state
      assert_equal Proc, ChildContext.transition(:parent_one).class
    end

    def test_singleton_transition_for_invalid_state
      assert_equal nil, ChildContext.transition(:foo)
    end

    def test_singleton_states
      assert_equal [:child_one, :child_two, :parent_two], ChildContext.states.sort_by {|ii| ii.to_s}
    end

    def test_at_state_pops_subsequent_states_off_list
      ctx = ChildContext.find_or_create
      ctx.states << :parent_one
      ctx.at_state(:start)
      assert_equal [:start], ctx.states
    end

    def test_state
      ctx = ChildContext.find_or_create
      ctx.states << :parent_one
      assert_equal :parent_one, ctx.state
    end

    def test_fire_transition
      ctx = ChildContext.find_or_create
      ctx.fire_transition(nil)
      ctx.reload
      assert_equal [:start, :parent_one], ctx.states
    end

  end # class ContextTest

end # module Flow
