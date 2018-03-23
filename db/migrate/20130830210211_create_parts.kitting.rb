# This migration comes from kitting (originally 20130520115517)
class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.string :number
      t.string :image_name
      t.text :description
      t.boolean :status

      t.timestamps
    end
  end
end
