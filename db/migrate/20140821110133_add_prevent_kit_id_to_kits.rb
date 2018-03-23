class AddPreventKitIdToKits < ActiveRecord::Migration
  def change
    add_column :kits, :parent_kit_id, :integer
  end
end
