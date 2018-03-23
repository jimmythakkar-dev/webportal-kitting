class CreateKittingPickTicketHistories < ActiveRecord::Migration
  def change
    create_table :kitting_pick_ticket_histories do |t|
      t.string :kit_number
      t.string :bincenter
      t.integer :kit_copy_id
      t.string :binlocation
      t.string :ordernolist
      t.string :created_by
      t.string :updated_by

      t.timestamps
    end
  end
  def down
    drop_table :kitting_pick_ticket_histories
  end
end
