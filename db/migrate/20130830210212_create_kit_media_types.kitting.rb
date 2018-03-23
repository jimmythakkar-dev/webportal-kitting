# This migration comes from kitting (originally 20130522060029)
class CreateKitMediaTypes < ActiveRecord::Migration
  def change
    create_table :kit_media_types do |t|
      t.string :name
      t.integer :compartment
      t.string :kit_type
      t.text :description

      t.timestamps
    end
  end
end
