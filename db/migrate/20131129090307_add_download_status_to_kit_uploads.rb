class AddDownloadStatusToKitUploads < ActiveRecord::Migration
  def change
    add_column :kit_uploads, :download_status, :boolean,:default => false
    add_index :kit_uploads, [:download_status], :name => "IKUP_DS"
  end
end
