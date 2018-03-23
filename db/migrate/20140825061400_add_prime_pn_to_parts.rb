class AddPrimePnToParts < ActiveRecord::Migration
  def change
    add_column :parts, :prime_pn, :string
  end
end
