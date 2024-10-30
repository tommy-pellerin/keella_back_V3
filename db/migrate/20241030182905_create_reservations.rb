class CreateReservations < ActiveRecord::Migration[7.2]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :workout, null: false, foreign_key: true, index: true
      t.integer :quantity
      t.float :total
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
