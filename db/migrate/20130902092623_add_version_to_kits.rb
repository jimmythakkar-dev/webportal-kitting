class AddVersionToKits < ActiveRecord::Migration
  def change
    add_column :kits, :current_version, :string
	end
end
