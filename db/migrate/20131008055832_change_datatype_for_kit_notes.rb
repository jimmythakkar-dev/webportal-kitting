class ChangeDatatypeForKitNotes < ActiveRecord::Migration
  def up
    change_column :kits, :notes, :string, :limit => 4000
  end
  def down
    change_column :kits, :notes, :string
  end
end
