namespace :blank_kit_media_type_cust_no do
  desc "Remove record having blank customer number entry in KIT MEDIA TYPE."
  task :remove => :environment do
     kit_media_count = Kitting::KitMediaType.where(:customer_number => nil).destroy_all
     puts "#{kit_media_count.count} record deleted successfully."
  end
end
