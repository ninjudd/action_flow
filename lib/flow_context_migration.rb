class FlowContextMigration < ActiveRecord::Migration
  def self.up
    create_table :flow_contexts do |t|
      t.string :key
      t.string :type
      t.text   :states
      t.text   :state_data
    end
    add_index :flow_contexts, :key, :unique => true
  end

  def self.down
    drop_table :flow_contexts
  end
end
