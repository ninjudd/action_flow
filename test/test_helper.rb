require 'set'
require 'test/unit'
require 'rubygems'
require 'mocha'
require 'pp'

$:.unshift File.dirname(__FILE__), File.dirname(__FILE__) + '/../lib'

require 'action_flow'
require 'flow_context_migration'
require 'action_controller/test_process'

ActiveRecord::Base.establish_connection(
  :adapter  => "postgresql",
  :host     => "localhost",
  :username => "postgres",
  :password => "",
  :database => "test"
)

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.connection.client_min_messages = 'panic'
