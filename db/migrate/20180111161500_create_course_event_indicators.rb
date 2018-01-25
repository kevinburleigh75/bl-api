class CreateCourseEventIndicators < ActiveRecord::Migration[5.1]
  def change
    create_table :course_event_indicators do |t|
      t.uuid      :course_uuid,                 null: false
      t.integer   :course_last_bundled_seqnum,  null: false
      t.boolean   :course_needs_attention,      null: false
      t.timestamp :course_waiting_since,        null: false

      t.timestamps null: false
    end

    add_index :course_event_indicators, :course_uuid,
                                        unique: true

    add_index :course_event_indicators, :course_needs_attention

    add_index :course_event_indicators, :course_waiting_since

    add_index :course_event_indicators, [:course_needs_attention, :course_waiting_since],
                                        name: 'index_ceis_on_cna_cws'
  end
end
