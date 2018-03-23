# This migration comes from kitting (originally 20130710061309)
class AddColumnBincenterToKits < ActiveRecord::Migration
  def change
    add_column :kits, :bincenter, :string
  end
end
