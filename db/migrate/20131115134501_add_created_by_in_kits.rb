class AddCreatedByInKits < ActiveRecord::Migration
  def up
  	add_column :kits, :created_by, :integer
  end

  def down
  	remove_column :kits, :created_by
  end
end
