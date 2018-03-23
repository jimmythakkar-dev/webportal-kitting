# This migration comes from kitting (originally 20130701110213)
class CreateKitFillingDetails < ActiveRecord::Migration
  def change
    create_table :kit_filling_details do |t|
      t.integer :kit_filling_id
      t.integer :cup_part_id
      t.string :filled_quantity

      t.timestamps
    end
  end
end
