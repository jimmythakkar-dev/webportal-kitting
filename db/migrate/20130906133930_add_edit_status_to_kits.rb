class AddEditStatusToKits < ActiveRecord::Migration
  def change
    add_column :kits, :edit_status, :string
  end
end
