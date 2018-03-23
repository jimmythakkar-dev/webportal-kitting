# This migration comes from kitting (originally 20130728070441)
class AddDetailsToCups < ActiveRecord::Migration
  def change
    add_column :cups, :ref1, :string
    add_column :cups, :ref2, :string
    add_column :cups, :ref3, :string
  end
end
