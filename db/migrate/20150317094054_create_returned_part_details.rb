# This migration comes from kitting (originally 20150317093419)
class CreateReturnedPartDetails < ActiveRecord::Migration
  def change
    create_table :returned_part_details do |t|
      t.string :work_order
      t.string :job_card_number
      t.string :job_card_description
      t.string :stage
      t.string :serial_number
      t.string :part_number
      t.string :quantity
      t.datetime :date_completed
      t.string :request_type
      t.string :requestor

      t.timestamps
    end
  end
end
