class AddCustomerKitPnToKits < ActiveRecord::Migration
  def up
    add_column :kits, :customer_kit_part_number, :string
    puts "Populating Customer Part Number with New Kit PN."
    # Populate customer kit part number field with original kit part number.
    Kitting::Kit.where(:category => "AD HOC").each do |kit|
      kit_num = kit.kit_number.split("#").first
      kit.update_attribute("customer_kit_part_number",kit_num)
    end
    puts "Updating Kit Number with Concatenated KitNumber#WorkOrder."
    # Update Kit part Number to Concatenation of Kit NUmber & Work Order.
    Kitting::KitWorkOrder.all.each do |kwo|
      updated_kit_number = "#{kwo.kit.kit_number}##{kwo.work_order.order_number}" rescue nil
      if updated_kit_number.present? && kwo.kit.present?
        kwo.kit.update_attribute("kit_number",updated_kit_number)
      end
    end
  end

  def down
    # Populate kit part number field with original kit part number.
    puts "Reverting Customer Part Number Details"
    Kitting::Kit.where(:category => "AD HOC").each do |kit|
      kit_num = kit.kit_number.split("#").first
      kit.update_attribute("kit_number",kit_num)
    end
    remove_column :kits, :customer_kit_part_number
  end
end