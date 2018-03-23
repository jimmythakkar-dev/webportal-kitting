class RemoveShopIdFromKits < ActiveRecord::Migration
  def up
    if column_exists?(:kits, :shop_id,:integer)
      remove_column :kits, :shop_id
    end
  end

  def down
    add_column :kits, :shop_id, :integer
  end
end
