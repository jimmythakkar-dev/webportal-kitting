class AddIndex < ActiveRecord::Migration
	def up
		unless index_exists?(:cup_parts, [:cup_id, :part_id])
			add_index :cup_parts, [:cup_id, :part_id]
		end
		unless index_exists?(:cups, [:kit_id,:commit_id])
			add_index :cups, [:kit_id,:commit_id]
		end
		unless index_exists?(:kit_copies, [:kit_id,:location_id,:customer_id])
			add_index :kit_copies, [:kit_id,:location_id,:customer_id]
		end
		unless index_exists?(:parts, :part_number, :unique => true)
			add_index :parts, :part_number, :unique => true
		end
		unless index_exists?(:kit_version_tracks,[:kit_id])
			add_index :kit_version_tracks,[:kit_id]
		end
		unless index_exists?(:customers,[:user_name])
			add_index :customers,[:user_name]
		end
		#unless index_exists?(:kit_filling_details,[:kit_filling_id,:cup_part_id])
		#	add_index :kit_filling_details,[:kit_filling_id,:cup_part_id],:name => "IKFD_KF_CP"
		#end
		#unless index_exists?(:kit_filling_histories,[:kit_filling_id,:location_id])
		#	add_index :kit_filling_histories,[:kit_filling_id,:location_id],:name => "IKFH_KF_LOC"
		#end
		#unless index_exists?(:kit_fillings,[:kit_copy_id,:location_id,:customer_id])
		#	add_index :kit_fillings,[:kit_copy_id,:location_id,:customer_id],:name => "IKF_KC_LOC_CUST"
		#end
		unless index_exists?(:kits,[:kit_number,:customer_id])
			add_index :kits,[:kit_number,:customer_id]
		end
		#unless index_exists?(:kitting_kit_order_fulfillments,[:kit_filling_id,:box_id,:cust_no,:created_at])
		#	add_index :kitting_kit_order_fulfillments,[:kit_filling_id,:box_id,:cust_no,:created_at],:name => "IKOF_BOX_CUST_CREATED_AT"
		#end
	end

	def down
		if index_exists?(:cup_parts, [:cup_id, :part_id])
			remove_index :cup_parts, [:cup_id, :part_id]
		end
		if index_exists?(:cups, [:kit_id,:commit_id])
			remove_index :cups, [:kit_id,:commit_id]
		end
		if index_exists?(:kit_copies, [:kit_id,:location_id,:customer_id])
			remove_index :kit_copies, [:kit_id,:location_id,:customer_id]
		end
		if index_exists?(:parts, [:part_number])
			remove_index :parts, [:part_number]
		end
		if index_exists?(:kit_version_tracks,[:kit_id])
			remove_index :kit_version_tracks,[:kit_id]
		end
		if index_exists?(:customers,[:user_name])
			remove_index :customers,[:user_name]
		end
		#if index_exists?(:kit_filling_details,[:kit_filling_id,:cup_part_id])
		#	remove_index :kit_filling_details,[:kit_filling_id,:cup_part_id]
		#end
		#if index_exists?(:kit_filling_histories,[:kit_filling_id,:location_id])
		#	remove_index :kit_filling_histories,[:kit_filling_id,:location_id]
		#end
		#if index_exists?(:kit_fillings,[:kit_copy_id,:location_id,:customer_id])
		#	remove_index :kit_fillings,[:kit_copy_id,:location_id,:customer_id]
		#end
		if index_exists?(:kits,[:kit_number,:customer_id])
			remove_index :kits,[:kit_number,:customer_id]
		end
		#if index_exists?(:kitting_kit_order_fulfillments,[:kit_filling_id,:box_id])
		#	remove_index :kitting_kit_order_fulfillments,[:kit_filling_id,:box_id]
		#end
	end
end
