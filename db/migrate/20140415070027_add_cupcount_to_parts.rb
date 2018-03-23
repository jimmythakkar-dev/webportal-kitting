class AddCupcountToParts < ActiveRecord::Migration
  def up
    add_column :parts, :large_cup_count, :integer
    add_column :parts, :medium_cup_count, :integer
    add_column :parts, :small_cup_count, :integer
  end

  def down
    remove_column :parts, :large_cup_count
    remove_column :parts, :medium_cup_count
    remove_column :parts, :small_cup_count
  end
end
