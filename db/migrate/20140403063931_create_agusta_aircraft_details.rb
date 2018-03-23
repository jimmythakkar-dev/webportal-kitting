class CreateAgustaAircraftDetails < ActiveRecord::Migration
  def change
    create_table :agusta_aircraft_details do |t|
      t.string :customer_number
      t.string :aircraft_id
      t.text :kit_part_numbers
      t.timestamps
    end
    add_index :agusta_aircraft_details, [:aircraft_id,:customer_number]
  end
end
