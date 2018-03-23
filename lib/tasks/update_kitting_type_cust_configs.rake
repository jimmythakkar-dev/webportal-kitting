namespace :update_kitting_type_cust_configs do
  desc "Update Kitting type to lean for all existing customers."
  task :update => :environment do
    Rails.logger.error "STARTED UPDATING KITTING TYPE FOR ALL CUSTOMERCONFIGURATIONS TO LEAN"
    puts "Started Updating kitting type..."
    ActiveRecord::Base.transaction do
       Kitting::CustomerConfigurations.update_all(:kitting_type => "LEAN")
    end
    puts "Successfully Updated Kitting type to LEAN"
  end
end