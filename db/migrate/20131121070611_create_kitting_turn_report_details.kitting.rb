# This migration comes from kitting (originally 20131121070204)
class CreateKittingTurnReportDetails < ActiveRecord::Migration
  def change
    create_table :kitting_turn_report_details do |t|
      t.string :kit_number
      t.string :kit_description
      t.integer :cup_no
      t.string :part_number
      t.integer :turns_copy1, :default => 0
      t.integer :turns_copy2, :default => 0
      t.integer :turns_copy3, :default => 0
      t.integer :turns_copy4, :default => 0
      t.integer :turns_copy5, :default => 0
      t.integer :turns_copy6, :default => 0
      t.integer :turns_copy7, :default => 0
      t.integer :turns_copy8, :default => 0
      t.integer :turns_copy9, :default => 0
      t.integer :turns_copy10, :default => 0

      t.timestamps
    end
  end
end
