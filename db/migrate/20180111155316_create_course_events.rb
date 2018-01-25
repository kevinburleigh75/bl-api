class CreateCourseEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :course_events do |t|
      t.uuid      :event_uuid,             null: false
      t.string    :event_type,             null: false
      t.jsonb     :event_data,             null: false
      t.boolean   :event_has_been_bundled, null: false
      t.uuid      :course_uuid,            null: false
      t.integer   :course_seqnum,          null: false

      t.timestamps null: false
    end

    add_index :course_events, :event_uuid,
                              unique: true

    add_index :course_events, [:course_uuid, :course_seqnum],
                              unique: true

    add_index :course_events, [:course_uuid, :event_has_been_bundled, :course_seqnum],
                              name: 'index_ces_on_cu_ehbb_csn'

    add_index :course_events, [:event_uuid, :event_has_been_bundled, :course_seqnum],
                              name: 'index_ces_on_eu_ehbb_csn'

    add_index :course_events, :course_uuid

    add_index :course_events, :event_has_been_bundled

    add_index :course_events, [:event_has_been_bundled, :course_uuid, :course_seqnum],
                              name: 'index_ces_on_ehbb_cu_csn'

  end
end
