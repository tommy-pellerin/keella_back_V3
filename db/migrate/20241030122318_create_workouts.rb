class CreateWorkouts < ActiveRecord::Migration[7.2]
  def change
    create_table :workouts do |t|
      t.string :title
      t.text :description
      t.text :equipments
      t.string :address
      t.string :city
      t.string :zip_code
      t.decimal :price_per_session, default: 0.0
      t.integer :max_participants
      t.references :host, foreign_key: { to_table: :users }, index: true
      t.belongs_to :category, index: true
      t.boolean :is_indoor, default: true
      t.boolean :host_present, default: true
      t.string :status, default: 0

      t.timestamps
    end
  end
end
