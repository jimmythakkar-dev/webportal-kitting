class AddIsBomDownloadToKitUploads < ActiveRecord::Migration
	def self.up
		add_column :kit_uploads, :is_bom_download, :boolean,:default => false
		unless index_exists?(:kit_uploads, [:customer_id,:is_bom_download])
			add_index :kit_uploads, [:customer_id,:is_bom_download],:name => "IKUP_CUST_BOM"
		end
	end

	def self.down
		if index_exists?(:kit_uploads, [:customer_id,:is_bom_download])
			remove_index :kit_uploads, [:customer_id,:is_bom_download]
		end
		remove_column :kit_uploads, :is_bom_download
	end
end
