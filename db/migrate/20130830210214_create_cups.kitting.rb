# This migration comes from kitting (originally 20130529103734)
class CreateCups < ActiveRecord::Migration
  def change
    create_table :cups do |t|
      t.integer :kit_id
      t.boolean :status

      t.timestamps
    end
  end
end
