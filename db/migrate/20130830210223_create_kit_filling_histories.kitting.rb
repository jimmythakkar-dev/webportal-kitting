# This migration comes from kitting (originally 20130619125624)
class CreateKitFillingHistories < ActiveRecord::Migration
  def change
    create_table :kit_filling_histories do |t|
      t.integer :kit_filling_id
      t.integer :filled_quantity
      t.integer :location_id

      t.timestamps
    end
  end
end
