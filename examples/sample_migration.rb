class CreateFlowContexts < ActiveRecord::Migration
  def self.up
    FlowContextMigration.up
  end

  def self.down
    FlowContextMigration.down
  end
end
