class RemoveColumnsFromCustomers < ActiveRecord::Migration
  def up
    update_cust_config
    remove_column :customers, :non_contract_part
    remove_column :customers, :multiple_part
    remove_column :customers, :prevent_kit_copy
    notify "REMOVED COLUMNS(NON CONTRACT PART, MULTIPLE PART, PREVENT KIT COPY) FROM CUSTOMERS"
  end

  def down
    add_column :customers, :non_contract_part, :boolean, :default => false
    add_column :customers, :multiple_part, :boolean, :default => false
    add_column :customers, :prevent_kit_copy, :boolean, :default => false
  end

  def update_cust_config
    notify "Starting to Upgrade Cust Config Database ..."
    customers = Kitting::Customer.where("cust_no is not null and cust_no != 'SYSTEM'")
    cust_nos = customers.pluck(:cust_no)
    # Create Cust Config Records from existing customers
    cust_nos.each do |cust_no|
      Kitting::CustomerConfigurations.find_or_create_by_cust_no(cust_no: cust_no)
    end
    # Update the Records based on Config from Customers
    Kitting::CustomerConfigurations.all.each do |cust_config|
      non_contract_part = Kitting::Customer.where(:cust_no => cust_config.cust_no,:non_contract_part => true)
      multiple_part = Kitting::Customer.where(:cust_no => cust_config.cust_no,:multiple_part => true)
      prevent_kit_copy = Kitting::Customer.where(:cust_no => cust_config.cust_no,:prevent_kit_copy => true)
      cust_name = non_contract_part.present? ? (non_contract_part.first.cust_name) : (multiple_part.present? ? (multiple_part.first.cust_name) : prevent_kit_copy.present? ? (prevent_kit_copy.first.cust_name) : "SYSTEM")
      cust_config.update_attributes(:non_contract_part => non_contract_part.present?, :multiple_part => multiple_part.present?, :prevent_kit_copy => prevent_kit_copy.present?,:cust_name => cust_name,:updated_by => "SYSTEM" )
      if cust_config.save
        notify "Configuration for #{cust_config.cust_no} Saved Successfully."
      else
        notify "Error Occured whle Saving Configuration for #{cust_config.cust_no}. Error => #{cust_config.errors} "
      end
    end
  end

  def notify(msg)
    puts msg
  end

end
