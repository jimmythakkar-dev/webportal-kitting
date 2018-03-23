class CreateKitVersionTracks < ActiveRecord::Migration
  def change
    create_table :kit_version_tracks do |t|
      t.binary :kit
      t.binary :cups
      t.binary :cup_parts
      t.string :kit_version
      t.integer :kit_id
      t.string :kit_number
      t.timestamps
    end
  end
end
