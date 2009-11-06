ActiveRecord::Schema.define do

  create_table :flow_contexts do |t|
    t.timestamps
    t.string :key
    t.string :type
    t.binary :states
    t.binary :state_data
  end

  add_index :flow_contexts, :key, :unique => true

end
