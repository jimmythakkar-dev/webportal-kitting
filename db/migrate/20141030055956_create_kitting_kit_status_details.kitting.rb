# This migration comes from kitting (originally 20141030055905)
class CreateKittingKitStatusDetails < ActiveRecord::Migration
  def change
    create_table :kitting_kit_status_details do |t|
      t.integer :kit_id
      t.integer :kit_copy_id
      t.string :updated_by
      t.string :reason

      t.timestamps
    end
  end
end
