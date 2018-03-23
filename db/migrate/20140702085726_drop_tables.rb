class DropTables < ActiveRecord::Migration
  def up
    drop_table :cup_parts_histories
    drop_table :kit_filling_histories
    drop_table :kit_uploads
    drop_table :kitting_pick_ticket_histories
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
