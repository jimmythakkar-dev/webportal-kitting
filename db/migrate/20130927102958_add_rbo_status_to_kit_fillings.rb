class AddRboStatusToKitFillings < ActiveRecord::Migration
  def change
    add_column :kit_fillings, :rbo_status, :string,:default => "Revoked"
  end
end
