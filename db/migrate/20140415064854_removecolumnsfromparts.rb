class Removecolumnsfromparts < ActiveRecord::Migration
  def up
    remove_column :parts, :customer_name
    remove_column :parts, :customer_id
    remove_column :parts, :commit_id
    remove_column :parts, :commit_status
  end

  def down
    add_column :parts, :customer_name, :string
    add_column :parts, :customer_id, :integer
    add_column :parts, :commit_id, :integer
    add_column :parts, :commit_status, :boolean
  end
end
