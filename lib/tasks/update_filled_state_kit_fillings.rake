namespace :update_filled_state_kit_fillings do
  desc "Update filled_state column for kit fillings for existing kits currently in filling."
  task :update => :environment do
    include Kitting::KitCopiesHelper
    Rails.logger.error "STARTED UPDATING FILLED_STATE FOR KIT_FILLINGS"
    puts "Started Updating Filled State..."
    ActiveRecord::Base.transaction do
      kit_copies = Kitting::KitCopy.all
      if kit_copies.present?
        count = not_count = 0
        kit_copies.each do |kit_copy|
          begin
            if kit_copy.kit_fillings.present?
              check_filling = kit_copy.kit_fillings.where(:flag => true)
              kit_filling_to_update = check_filling.last
              if kit_filling_to_update.present?
                kit_fill_state = find_kit_current_filled_state(kit_filling_to_update)
                kit_filling_to_update.update_attributes(:filled_state => kit_fill_state)
                count = count + 1
                Rails.logger.error "Updated Filled State for #{kit_copy.kit_version_number} to #{kit_fill_state}"
                puts "Updated Filled State for #{kit_copy.kit_version_number} to #{kit_fill_state}"
              end
            end
          rescue => e
            Rails.logger.error "Failed Updating  #{kit_copy.kit_version_number}"
          end
        end
      end
      Rails.logger.error "#{count} KitFilling filled_state  Updated."
      puts "Filled State updated for #{count} KitFillings."
    end
  end
end