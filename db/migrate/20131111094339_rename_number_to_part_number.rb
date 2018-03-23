class RenameNumberToPartNumber < ActiveRecord::Migration
  def up
  	rename_column :parts, :number, :part_number
  end

  def down
  	rename_column :parts, :part_number, :number
  end
end
