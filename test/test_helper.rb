require 'set'
require 'test/unit'
require 'rubygems'
require 'mocha'
require 'pp'

$:.unshift File.dirname(__FILE__), File.dirname(__FILE__) + '/../lib'

require 'boot' unless defined?(ActiveRecord)

require 'active_record'
require 'active_support'
require 'action_controller'
require 'action_controller/test_process'

class Test::Unit::TestCase

end
