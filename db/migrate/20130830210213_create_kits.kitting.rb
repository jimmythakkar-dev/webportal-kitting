# This migration comes from kitting (originally 20130523131840)
class CreateKits < ActiveRecord::Migration
  def change
    create_table :kits do |t|
      t.integer :kit_media_type_id
      t.string :customer_code
      t.integer :shop_id
      t.string :kit_number
      t.boolean :flag

      t.timestamps
    end
  end
end
