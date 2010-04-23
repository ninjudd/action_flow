class FlowContextMigration < ActiveRecord::Migration
  def self.up
    create_table :flow_contexts do |t|
      t.timestamps
      t.string :key
      t.string :type
      t.binary :states
      t.binary :state_data
      t.text   :final_destination
    end
    add_index :flow_contexts, :key, :unique => true
  end

  def self.down
    drop_table :flow_contexts
  end
end
