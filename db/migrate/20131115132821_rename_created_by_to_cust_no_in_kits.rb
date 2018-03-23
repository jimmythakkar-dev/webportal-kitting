class RenameCreatedByToCustNoInKits < ActiveRecord::Migration
  def up
  	rename_column :kits, :created_by, :cust_no
  end

  def down
  	rename_column :parts, :cust_no, :created_by
  end
end
