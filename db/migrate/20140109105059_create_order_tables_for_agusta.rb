class CreateOrderTablesForAgusta < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string  :order_number, null: false
      t.string  :order_type, null: false
      t.string  :order_status
      t.string  :customer_name, null: false
      t.string  :customer_number, null: false
      t.string  :project_id, null: false
      t.string  :station_name, null: false
      t.string  :discharge_point_name, null: false
      t.string  :kit_part_number, null: false
      t.string  :created_by, null: false
			t.string  :updated_by
      t.string  :remark
			t.timestamps
		end

    create_table :order_part_details do |t|
      t.references  :order
      t.string      :part_number, null: false
      t.integer     :quantity
      t.string      :reason_code
			t.string      :note
			t.datetime    :fulfilment_date_time
			t.datetime    :shipment_date_time
      t.string      :carrier_name
			t.timestamps
		end

    add_index :orders, :order_number
    add_index :orders, :customer_number
    add_index :orders, :created_at
    add_index :orders, :updated_at
    add_index :order_part_details, :created_at
    add_index :order_part_details, :updated_at
    add_index :order_part_details, :order_id

  end
end
