namespace :capitalize_part_numbers do
  desc "Capitalizing Existing lower case Part Numbers into table. "
  task :update => :environment do
    Rails.logger.error ".......... Updating lower case part numbers................\n"
    puts ".......... Updating lower case part numbers................"
    lower_case_parts =  Kitting::Part.find_by_sql("SELECT * FROM parts WHERE REGEXP_LIKE (part_number, '([a-z]+)')")
    kit_filling_histories_lower_case_part = Kitting::KitFillingHistoryReport.find_by_sql("SELECT * FROM kit_filling_history_reports WHERE REGEXP_LIKE (part_number, '([a-z]+)')")
    turn_report_lower_case_parts = Kitting::TurnReportDetail.find_by_sql("SELECT * FROM kitting_turn_report_details WHERE REGEXP_LIKE (part_number, '([a-z]+)')")
    if lower_case_parts.blank?
      puts ".......... No part numbers to capitalize................"
      Rails.logger.error ".......... No part numbers to capitalize................\n"
    else
      lower_case_parts.each do |low_case_part|
        begin
          ActiveRecord::Base.transaction do
            if low_case_part.part_number.present?
              upper_case_part = Kitting::Part.where("part_number=upper('#{low_case_part.part_number}')").first
              if upper_case_part.present?
                #Remove lower case part and update all the references with the upper case part object
                cup_part_entries = Kitting::CupPart.where(:part_id => low_case_part.id)
                if cup_part_entries.present?
                  cup_part_entries.each do |cup_part|
                    unless cup_part.part_id.blank?
                      cup_part.update_attribute('part_id', upper_case_part.id) unless cup_part.id.blank?
                      puts "Part Number #{cup_part.part.part_number} Updated ..."
                      Rails.logger.error ".......... #{cup_part.part.part_number} Updated................\n"
                    end
                  end
                end
                puts "Part Number #{low_case_part.part_number} Deleted ..."
                Rails.logger.error ".......... Part Number #{low_case_part.part_number} Deleted................\n"
                low_case_part.delete
              else
                low_case_part.update_attribute('part_number',low_case_part.part_number.upcase)
                puts "Part Number #{low_case_part.part_number} Updated ..."
                Rails.logger.error ".......... #{low_case_part.part_number} Updated................\n"
              end
            end
          end
        rescue => e
          Rails.logger.error ".......... #{low_case_part.part_number} not Updated................\n"
          puts "Part Number #{low_case_part.part_number} not Updated ..."
        end
      end
    end

    # Updating Kit Filling Tracking Reports Table Part Numbers
    unless kit_filling_histories_lower_case_part.blank?
      kit_filling_histories_lower_case_part.each do |filling_part|
        begin
         filling_part.update_attribute('part_number', filling_part.part_number.upcase)
          Rails.logger.error ".......... #{filling_part.part_number}  Updated in Filling Tracking Report Table................\n"
          puts "Part Number #{filling_part.part_number}  Updated in Filling Tracking Report Table..."
        rescue => e
          Rails.logger.error ".......... #{filling_part.part_number}  Not Updated in Filling Tracking Report Table................\n"
          puts "Part Number #{filling_part.part_number}  Not Updated in Filling Tracking Report Table..."
        end
      end
    end

    # Updating Turn Report Details Table Part Numbers
    unless turn_report_lower_case_parts.blank?
      turn_report_lower_case_parts.each do |turn_report_path|
        begin
          turn_report_path.update_attribute('part_number', turn_report_path.part_number.upcase)
          Rails.logger.error ".......... #{turn_report_path.part_number}  Updated in Filling Tracking Report Table................\n"
          puts "Part Number #{turn_report_path.part_number}  Updated in Turn Report Details Table..."
        rescue => e
          Rails.logger.error ".......... #{turn_report_path.part_number}  Not Updated in Turn Report Details Table................\n"
          puts "Part Number #{turn_report_path.part_number}  Not Updated in Turn Report Details Table..."
        end
      end
    end
  end
end