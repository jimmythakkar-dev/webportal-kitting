# This migration comes from kitting (originally 20130619125514)
class CreateKitFillings < ActiveRecord::Migration
  def change
    create_table :kit_fillings do |t|
      t.integer :kit_id
      t.integer :cup_id
      t.integer :part_id
      t.integer :filled_quantity
      t.integer :location_id

      t.timestamps
    end
  end
end
