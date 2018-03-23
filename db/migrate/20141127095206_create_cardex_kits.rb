class CreateCardexKits < ActiveRecord::Migration
  def change
    create_table :cardex_kits do |t|
      t.string :kit_number
      t.string :parent_kit_id
      t.integer :kit_media_type_id
      t.text :kit_html_layout
      t.string :box_number
      t.string :created_by
      t.string :updated_by
      t.timestamps
    end
  end
end