class CreateAvailabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :availabilities do |t|
      t.belongs_to :workout, index: true
      t.datetime :start_date, null: false
      t.time :start_time, null: false
      t.time :end_date, null: false
      t.integer :duration, null: false
      t.boolean :is_booked

      t.timestamps
    end
  end
end
