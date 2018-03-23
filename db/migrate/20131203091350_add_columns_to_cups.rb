class AddColumnsToCups < ActiveRecord::Migration
  def change
    add_column :cups, :cup_dimension, :string
    add_column :cups, :cup_number, :integer
  end
end
