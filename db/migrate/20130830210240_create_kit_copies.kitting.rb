# This migration comes from kitting (originally 20130704070322)
class CreateKitCopies < ActiveRecord::Migration
  def change
    create_table :kit_copies do |t|
      t.integer :from
      t.integer :to
      t.timestamps
    end
  end
end
