# This migration comes from kitting (originally 20130626092358)
class CreateCupPartsHistories < ActiveRecord::Migration
  def change
    create_table :cup_parts_histories do |t|
      t.integer :cup_part_id, null: false
      t.integer :cup_id, null: false
      t.integer :part_id, null: false
      t.string :demand_quantity, null: false
      t.boolean :status, null: false

      t.timestamps
    end
  end
  def down
    drop_table :cup_parts_histories
  end
end
