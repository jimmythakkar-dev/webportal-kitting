class AddMultiplePartToCoustomers < ActiveRecord::Migration
  def change
    add_column :customers, :multiple_part, :boolean, :default => false
  end
end
