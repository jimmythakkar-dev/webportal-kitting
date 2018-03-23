class AddCommitIdAndCommitStatusToKitAndAssociations < ActiveRecord::Migration
	def self.up
			add_column :kits, :commit_id, :integer
			add_column :kits, :commit_status, :boolean
			add_column :cups, :commit_id, :integer
			add_column :cups, :commit_status, :boolean
			add_column :cup_parts, :commit_id, :integer
			add_column :cup_parts, :commit_status, :boolean
			add_column :parts, :commit_id, :integer
			add_column :parts, :commit_status, :boolean
	end
	def self.down
		remove_column :kits, :commit_id
		remove_column :kits, :commit_status
		remove_column :cups, :commit_id
		remove_column :cups, :commit_status
		remove_column :cup_parts, :commit_id
		remove_column :cup_parts, :commit_status
		remove_column :parts, :commit_id
		remove_column :parts, :commit_status
	end
end
