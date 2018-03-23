# This migration comes from kitting (originally 20130617115233)
class AddLocationIdToKits < ActiveRecord::Migration
  def change
    add_column :kits, :location_id, :integer
  end
end
