class CreateBookContainers < ActiveRecord::Migration[5.1]
  def change
    create_table :book_containers do |t|
      t.uuid :container_uuid, null: false
      t.uuid :ecosystem_uuid, null: false

      t.timestamps null: false
    end

    add_index :book_containers, :container_uuid,
                                unique: true

    add_index :book_containers, :ecosystem_uuid
  end
end
