class AddCurrentVersionToKitCopies < ActiveRecord::Migration
  def change
    add_column :kit_copies, :version_status, :string
  end
end
