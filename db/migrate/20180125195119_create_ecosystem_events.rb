class CreateEcosystemEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :ecosystem_events do |t|
      t.uuid    :event_uuid,             null: false
      t.string  :event_type,             null: false
      t.jsonb   :event_data,             null: false
      t.boolean :event_has_been_bundled, null: false
      t.uuid    :ecosystem_uuid,         null: false
      t.integer :ecosystem_seqnum,       null: false

      t.timestamps null: false
    end

    add_index :ecosystem_events, :event_uuid,
                                 unique: true

    add_index :ecosystem_events, [:ecosystem_uuid, :ecosystem_seqnum],
                                 unique: true

    add_index :ecosystem_events, [:ecosystem_uuid, :event_type]
  end
end
