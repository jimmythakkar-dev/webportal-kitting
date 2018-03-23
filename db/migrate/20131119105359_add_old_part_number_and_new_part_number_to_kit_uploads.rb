class AddOldPartNumberAndNewPartNumberToKitUploads < ActiveRecord::Migration
  def change
    add_column :kit_uploads, :old_part_number, :string
    add_column :kit_uploads, :new_part_number, :string
  end
end
