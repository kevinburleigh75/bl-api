class CreateStudentClues < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'

    create_table :student_clues do |t|
      t.uuid   :clue_uuid,            null: false
      t.citext :clue_algorithm_name,  null: false
      t.jsonb  :clue_data,            null: false
      t.uuid   :student_uuid,         null: false
      t.uuid   :book_container_uuid,  null: false

      t.timestamps null: false
    end

    add_index :student_clues, :clue_uuid,
                              unique: true

    add_index :student_clues, :book_container_uuid,
                              unique: true

    add_index :student_clues, [:student_uuid, :book_container_uuid, :clue_algorithm_name],
                              unique: true,
                              name: 'index_scs_on_su_bcu_can'
  end
end
