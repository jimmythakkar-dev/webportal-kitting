class AddPartBincenterToKits < ActiveRecord::Migration
  def change
    add_column :kits, :part_bincenter, :string
  end
end
