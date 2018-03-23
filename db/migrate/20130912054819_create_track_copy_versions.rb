class CreateTrackCopyVersions < ActiveRecord::Migration
  def change
    create_table :track_copy_versions do |t|
      t.references :kit_copy
      t.string :version
      t.string :picked_version
      t.string :filled_version

      t.timestamps
    end
    add_index :track_copy_versions, :kit_copy_id
  end
end
