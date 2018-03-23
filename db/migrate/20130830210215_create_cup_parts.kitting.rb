# This migration comes from kitting (originally 20130531073251)
class CreateCupParts < ActiveRecord::Migration
  def change
    create_table :cup_parts do |t|
      t.integer :cup_id
      t.integer :part_id
      t.integer :demand_quantity
      t.integer :filled_quantity
      t.integer :action

      t.timestamps
    end
  end
end
