class CreateKitBomBulkOperations < ActiveRecord::Migration
	def change
		create_table :kit_bom_bulk_operations do |t|
			t.string :operation_type
			t.string :file_path
			t.string :status
			t.references :customer
			t.string :kit_number
			t.string :bin_center
			t.string :part_number
			t.string :new_part_number
			t.string :old_part_number
			t.boolean :is_downloaded,:default => false

			t.timestamps
		end
		add_index :kit_bom_bulk_operations, :customer_id
		add_index :kit_bom_bulk_operations, :file_path , :unique => true, :name => 'INDEX_BOM_OPS'
	end
end