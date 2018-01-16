class CreateCourseEventIndicators < ActiveRecord::Migration[5.1]
  def change
    create_table :course_event_indicators do |t|
      t.uuid      :course_uuid,         null: false
      t.integer   :last_course_seqnum,  null: false
      t.boolean   :needs_attention,     null: false
      t.timestamp :waiting_since,       null: false

      t.timestamps null: false
    end

    add_index :course_event_indicators, :course_uuid,
                                        unique: true

    add_index :course_event_indicators, :needs_attention

    add_index :course_event_indicators, :waiting_since

    add_index :course_event_indicators, [:needs_attention, :waiting_since],
                                        name: 'index_ceis_on_na_ws'
  end
end
