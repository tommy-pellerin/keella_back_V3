class CreateAvailabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :availabilities do |t|
      t.belongs_to :workout, index: true
      t.datetime :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :max_participants
      t.integer :slot
      t.timestamps
    end
  end
end
