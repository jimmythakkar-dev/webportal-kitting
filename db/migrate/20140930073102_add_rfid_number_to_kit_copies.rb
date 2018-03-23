class AddRfidNumberToKitCopies < ActiveRecord::Migration
  def change
    add_column :kit_copies, :rfid_number, :string
    add_index :kit_copies, :rfid_number, :unique => true
  end
end
