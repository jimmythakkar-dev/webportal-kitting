class AddColumnDeletedToKits < ActiveRecord::Migration
  def change
    add_column :kits, :deleted, :boolean, :default => false
  end
end
