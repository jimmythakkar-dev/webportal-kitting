# This migration comes from kitting (originally 20130827143109)
class AddKitNotesAndDescriptionToKits < ActiveRecord::Migration
  def self.up
    add_column :kits, :notes, :string
    add_column :kits, :description, :string
	end
	def self.down
		remove_column :kits, :notes
		remove_column :kits, :description
	end
end
