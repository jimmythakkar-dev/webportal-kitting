# This migration comes from kitting (originally 20130626082459)
class AddCreatedByToKits < ActiveRecord::Migration
  def change
    add_column :kits, :created_by, :string
  end
end
