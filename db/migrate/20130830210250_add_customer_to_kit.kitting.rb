# This migration comes from kitting (originally 20130826102239)
class AddCustomerToKit < ActiveRecord::Migration
  def self.up
    #add_column :kits, :customer_id, :integer
		change_table :kits do |t|
			t.references :customer, index: true
		end
		change_table :kit_media_types do |t|
			t.references :customer, index: true
		end
		change_table :kit_copies do |t|
			t.references :customer, index: true
		end
		change_table :kit_fillings do |t|
			t.references :customer, index: true
		end
		change_table :parts do |t|
			t.references :customer, index: true
		end
	end
	def self.down
		change_table :kits do |t|
			t.remove :customer_id
		end
		change_table :kit_media_types do |t|
			t.remove :customer_id
		end
		change_table :kit_copies do |t|
			t.remove :customer_id
		end
		change_table :kit_fillings do |t|
			t.remove :customer_id
		end
		change_table :parts do |t|
			t.remove :customer_id
		end
	end
end
