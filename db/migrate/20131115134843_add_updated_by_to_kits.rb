class AddUpdatedByToKits < ActiveRecord::Migration
  def change
    add_column :kits, :updated_by, :integer
  end
end
