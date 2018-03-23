class CreateKitUploads < ActiveRecord::Migration
  def change
    create_table :kit_uploads do |t|
      t.string :file_path
      t.string :status
      t.references :customer
      t.timestamps
    end
    add_index :kit_uploads, :customer_id
  end
end
