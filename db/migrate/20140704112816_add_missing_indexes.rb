# https://github.com/plentz/lol_dba
class AddMissingIndexes < ActiveRecord::Migration
  def up
    puts "Adding Index on KIT FILLING, KIT & KIT MEDIA TYPE"
    add_index :kit_fillings, :kit_copy_id
    add_index :kit_fillings, :location_id
    add_index :kit_fillings, :customer_id
    add_index :kits, :kit_media_type_id
    add_index :kit_media_types, :customer_id
  end

  def down
    puts "Removing Indexes"
    remove_index :kit_fillings, :kit_copy_id
    remove_index :kit_fillings, :location_id
    remove_index :kit_fillings, :customer_id
    remove_index :kits, :kit_media_type_id
    remove_index :kit_media_types, :customer_id
  end
end
