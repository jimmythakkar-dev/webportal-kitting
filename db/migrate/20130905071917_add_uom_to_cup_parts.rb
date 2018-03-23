class AddUomToCupParts < ActiveRecord::Migration
  def change
    add_column :cup_parts, :uom, :string
  end
end
