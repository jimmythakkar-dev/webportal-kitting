class AddTypeToKits < ActiveRecord::Migration
  def up
    add_column :kits, :category, :string
  end

  def down
    remove_column :kits, :category
  end
end