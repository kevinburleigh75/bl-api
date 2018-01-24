class CreateStudentClues < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'

    create_table :student_clues do |t|
      t.uuid   :student_clue_uuid,   null: false
      t.uuid   :student_uuid,        null: false
      t.uuid   :book_container_uuid, null: false
      t.citext :algorithm_name,      null: false
      t.jsonb  :data,                null: false

      t.timestamps                   null: false
    end

    add_index :student_clues, :student_clue_uuid,
                              unique: true

    add_index :student_clues, :book_container_uuid,
                              unique: true

    add_index :student_clues, [:student_uuid, :book_container_uuid, :algorithm_name],
                              unique: true,
                              name: 'index_scs_on_su_bcu_an'
  end
end
