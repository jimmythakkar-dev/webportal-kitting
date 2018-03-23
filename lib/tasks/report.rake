namespace :report do
  desc "Make entries in Kit Filling Histories Report Tables"
  task :kit_filling_history_report_entries => :environment do
    @data_exist = Kitting::KitFillingHistoryReport.all

    if @data_exist.blank?
      @kit_filling = Kitting::KitFilling.find(:all,:include =>[:kit_copy,:customer,{:kit_filling_details=>{:cup_part=>:part}}])
      unless  @kit_filling.blank?
        @kit_filling.each do |kit_filling|
            kit_filling.kit_filling_details.each do |kit_filling_details|
            if ( (kit_filling_details.try(:cup_part).try(:demand_quantity) != "WL" || kit_filling_details.try(:cup_part).try(:demand_quantity) != "S") and kit_filling_details.filled_quantity == "E")
              fill_qty = "0"
            elsif (kit_filling_details.try(:cup_part).try(:demand_quantity) == "WL" and kit_filling_details.filled_quantity == "0")
              fill_qty = "E"
            elsif (kit_filling_details.try(:cup_part).try(:demand_quantity) == "S" and kit_filling_details.filled_quantity == "S")
              fill_qty = "E"
            else
              fill_qty = kit_filling_details.filled_quantity
            end
            @filling_histories_details = {:kit_number=> kit_filling.try(:kit_copy).try(:kit).try(:kit_number),:kit_copy_number=>kit_filling.try(:kit_copy).try(:kit_version_number),:customer_number=>kit_filling.try(:customer).try(:cust_no),:cup_no=>kit_filling_details.try(:cup_part).try(:cup).try(:cup_number),:part_number=>kit_filling_details.try(:cup_part).try(:part).try(:part_number),:demand_qty=>kit_filling_details.try(:cup_part).try(:demand_quantity),:filled_qty=>fill_qty,:filling_date=>kit_filling.try(:created_at),:created_by=>kit_filling.try(:customer).try(:user_name), :kit_filling_id => kit_filling.id ,:cup_part_id => kit_filling_details.try(:cup_part).try(:id),:cup_part_status => kit_filling_details.try(:cup_part).try(:status), :cup_part_commit_status => kit_filling_details.try(:cup_part).try(:commit_status)}
            Kitting::KitFillingHistoryReport.create(@filling_histories_details)
          end
        end
      end
      puts "Entries in Kit Filling Histories Report Tables Save Successfully...!!!"
    else
      Kitting::KitFillingHistoryReport.destroy_all
      @kit_filling = Kitting::KitFilling.find(:all,:include =>[:kit_copy,:customer,{:kit_filling_details=>{:cup_part=>:part}}])
      unless  @kit_filling.blank?
          @kit_filling.each do |kit_filling|
          kit_filling.kit_filling_details.each do |kit_filling_details|
            if ( (kit_filling_details.try(:cup_part).try(:demand_quantity) != "WL" || kit_filling_details.try(:cup_part).try(:demand_quantity) != "S") and kit_filling_details.filled_quantity == "E")
              fill_qty = "0"
            elsif (kit_filling_details.try(:cup_part).try(:demand_quantity) == "WL" and kit_filling_details.filled_quantity == "0")
              fill_qty = "E"
            elsif (kit_filling_details.try(:cup_part).try(:demand_quantity) == "S" and kit_filling_details.filled_quantity == "S")
              fill_qty = "E"
            else
              fill_qty = kit_filling_details.filled_quantity
            end
            @filling_histories_details = {:kit_number=> kit_filling.try(:kit_copy).try(:kit).try(:kit_number),:kit_copy_number=>kit_filling.try(:kit_copy).try(:kit_version_number),:customer_number=>kit_filling.try(:customer).try(:cust_no),:cup_no=>kit_filling_details.try(:cup_part).try(:cup).try(:cup_number),:part_number=>kit_filling_details.try(:cup_part).try(:part).try(:part_number),:demand_qty=>kit_filling_details.try(:cup_part).try(:demand_quantity),:filled_qty=>fill_qty,:filling_date=>kit_filling.try(:created_at),:created_by=>kit_filling.try(:customer).try(:user_name), :kit_filling_id => kit_filling.id ,:cup_part_id => kit_filling_details.try(:cup_part).try(:id),:cup_part_status => kit_filling_details.try(:cup_part).try(:status), :cup_part_commit_status => kit_filling_details.try(:cup_part).try(:commit_status)}
            Kitting::KitFillingHistoryReport.create(@filling_histories_details)
          end
        end
      end
      puts "Entries in Kit Filling Histories Report Tables Update Successfully...!!!"
    end
  end
end
