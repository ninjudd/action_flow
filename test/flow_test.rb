require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require 'flow'

class DummyFlowContext < Flow::Context

  state :start do
    transition :one
  end

  state :one do
    transition :two
  end

  state :two

end

class DummyController < ActionController::Base
  include Flow
  flow :dummy
end

class FlowTest < Test::Unit::TestCase

  def test_flow_class_macro_includes_flow_helper
    assert_equal true, DummyController.master_helper_module.include?(Flow::Helper), 'flow class macro should add Flow::Helper'
  end

  def test_flow_class_macro_adds_context_method
    assert_equal true, DummyController.private_methods.include?('context'), 'flow class macro should add :context method'
  end

  def test_flow_class_macro_adds_state_methods
    DummyFlowContext.states.each do |state|
      assert_equal true, DummyController.methods.include?(state.to_s), "flow class macro should add :#{state} method"
    end
  end

  def test_flow_class_macro_adds_next_method
    assert_equal true, DummyController.methods.include?('next'), 'flow class macro should add :next method'
  end

end # class FlowTest

