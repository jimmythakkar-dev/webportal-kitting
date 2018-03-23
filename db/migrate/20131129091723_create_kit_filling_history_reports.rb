class CreateKitFillingHistoryReports < ActiveRecord::Migration
  def up
    create_table :kit_filling_history_reports do |t|
      t.string :kit_number
      t.string :kit_copy_number
      t.string :customer_number
      t.integer :cup_no
      t.string :part_number
      t.string :demand_qty
      t.string :filled_qty
      t.string :created_by
      t.datetime :filling_date
      t.integer :kit_filling_id
      t.integer :cup_part_id
      t.integer :cup_part_status
      t.integer :cup_part_commit_status
      t.timestamps
    end
  end

  def down
    drop_table :kit_filling_history_reports
  end
end
