namespace :calculate_turn_count_for_old_data do
  desc "Calculating TurnCount of old data and Inserting its data into the table"
  task :update => :environment do

    @report_data = Kitting::KitFilling.joins('LEFT JOIN kit_filling_details ON kit_fillings.id = kit_filling_details.kit_filling_id').group("kit_fillings.kit_copy_id, kit_filling_details.cup_part_id, to_date(to_char(kit_fillings.created_at,'DD-MM-YYYY'), 'DD-MM-YYYY'), kit_fillings.created_by").order('kit_fillings.kit_copy_id asc').select("sum(kit_filling_details.turn_count) AS total_count, kit_fillings.kit_copy_id,kit_filling_details.cup_part_id, to_date(to_char(kit_fillings.created_at,'DD-MM-YYYY'), 'DD-MM-YYYY') as created_at, kit_fillings.created_by")
    unless @report_data.blank?
      count = 0
      @report_data.each do |data|
        begin
          created_at = data.try(:created_at)
          created_by = data.try(:created_by)
          kit_number = data.try(:kit_copy).try(:kit).try(:kit_number)
          kit_media_type = data.try(:kit_copy).try(:kit).try(:kit_media_type).try(:name)
          description = data.try(:kit_copy).try(:kit).try(:description)
          part_description = Kitting::CupPart.find_by_id(data.try(:cup_part_id)).try(:part).try(:name)
          cup_part = data.try(:cup_part_id)
          cup_id =  Kitting::CupPart.find_by_id(data.try(:cup_part_id)).try(:cup).try(:id)
          copy_entry = data.try(:kit_copy).try(:kit_version_number)
          config.logger.warn "Starting to calculate count. Kit Version Number = #{copy_entry}"
          if copy_entry.present?
            turn_copy_number = copy_entry.split("-").try(:last)
            if turn_copy_number.to_i <= 10
              cup_number = 0
              cups = data.try(:kit_copy).try(:kit).try(:cups)
              if cups.present?
                cup_number = cups.index{|cup| cup.id == cup_id }
                if cup_number.blank?
                  cup_number = 0
                else
                  cup_number = cup_number + 1
                end
              end

              part_number = Kitting::CupPart.find_by_id(data.try(:cup_part_id)).try(:part).try(:part_number)
              @turn_count_record = Kitting::TurnReportDetail.where("kit_number = ? AND cup_no = ? AND part_number = ? AND (created_at between ? and ?)",kit_number, cup_number, part_number, data.created_at.in_time_zone.beginning_of_day, data.created_at.in_time_zone.end_of_day).first
              if @turn_count_record.blank?
                @report_detail_entry = Kitting::TurnReportDetail.create(:kit_number => kit_number, :kit_description => description, :cup_no => cup_number,:part_number => part_number, :"turns_copy#{turn_copy_number}".to_sym => data.total_count, :part_description => part_description, :kit_media_type => kit_media_type, :cust_no => data.created_by)
                @report_detail_entry.update_attribute(:created_at , data.created_at)
                count = count + 1
              else
                if !turn_copy_number.blank?
                  temp = "turns_copy" + turn_copy_number
                end
                turn_column = @turn_count_record.send(temp)
                @turn_count_record.update_attribute(temp, data.total_count)
              end
            end
          end
        rescue => e
          config.logger.warn "Failed Creating/Updating entry. #{e.backtrace} "
          puts "Failed Creating/Updating entry #{data.inspect}"
        end
      end
      puts "#{count} Records Inserted"
    end
  end
end