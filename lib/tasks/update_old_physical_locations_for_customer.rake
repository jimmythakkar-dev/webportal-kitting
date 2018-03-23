namespace :update_old_physical_locations_for_customer do
  desc "Update Customer number for all old physical locations."
  task :update => :environment do
    Rails.logger.error "STARTED UPDATING CUSTOMER NUMBER IN ALL PHYSICAL LOCATIONS TO 029540"
    puts "Started Updating Cust Nos..."
    ActiveRecord::Base.transaction do
      restricted_locations = ['Send to Stock', 'SOS Queue', 'NEW KIT QUEUE', 'Ship/Invoice', 'Picking Queue']
      locations = Kitting::Location.where('name not in (?)', restricted_locations)
      if locations.present?
        count = not_count = 0
        locations.each do |location|
          begin
            location.update_attribute('customer_number','029540')
            count = count + 1
            Rails.logger.error "Successfully Updated #{location.name}"
            puts "Successfully Updated #{location.name}"
          rescue => e
            not_count = not_count + 1
            Rails.logger.error "Failed Updating location #{location.name}"
          end
        end
        Rails.logger.error "#{count} Locations Updated."
        Rails.logger.error "#{not_count} Locations UnUpdated."
        puts  "\n#{count} Locations  Successfully Updated."
        puts  "#{not_count} Locations Failed."
      else
        Rails.logger.error "No locations to update."
        puts "No locations to update."
      end
    end
  end
end