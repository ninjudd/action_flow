require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class DummyFlowContext < ActionFlow::Context
  state :start do
    transition :one
  end

  state :one do
    transition :two
  end

  state :two
end

class DummyController < ActionController::Base
  flow :dummy
end

class ActionFlowTest < Test::Unit::TestCase
  def test_flow_class_macro_includes_flow_helper
    assert_equal true, DummyController.master_helper_module.include?(ActionFlow::Helper)
  end

  def test_flow_class_macro_adds_context_method
    assert_equal true, DummyController.private_instance_methods.include?('context')
  end

  def test_flow_class_macro_adds_state_methods
    DummyFlowContext.states.each do |state|
      assert_equal true, DummyController.instance_methods.include?(state.to_s)
    end
  end

  def test_flow_class_macro_adds_next_method
    assert_equal true, DummyController.instance_methods.include?('next')
  end
end

