class CreateAgustaStations < ActiveRecord::Migration
  def change
    create_table :agusta_stations do |t|
      t.string :name
      t.string :station_type
      t.string :customer_number
      t.timestamps
    end
    add_index :agusta_stations, [:name,:station_type,:customer_number]
  end
end
