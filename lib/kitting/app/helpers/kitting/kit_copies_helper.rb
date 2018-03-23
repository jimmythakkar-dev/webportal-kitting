module Kitting
  module KitCopiesHelper
    def rate code
      case code
        when "X"
          return 1
        when "Y"
          return 2
        when "Z"
          return 3
        else
          return ""
      end
    end

    def find_cup_part_demand_qty(cup_part_id)
      @cup = Kitting::CupPart.find_by_id(cup_part_id)
      @cup.demand_quantity
    end

    def find_filled_state(demand_quantity,filled_quantity,status=false)
      if(demand_quantity == "Water-Level"  || demand_quantity == "WL" || filled_quantity == 'WL' || filled_quantity == "S" || filled_quantity == "E")
        demand_qty = demand_quantity.upcase
        filled_qty = filled_quantity.upcase
      else
        operator = status ? :to_f : :to_i
        demand_qty = demand_quantity.send(operator)
        filled_qty = filled_quantity.send(operator)
      end
      if(demand_qty == filled_qty || (demand_qty == "Water-Level" && filled_qty == "WL"))
        filled_state = 'F'
      else
        if((filled_qty == 'S' || filled_qty == "E"))
          if(filled_qty == 'S')
            filled_state = 'P'
          elsif(filled_qty == 'E')
            filled_state = 'E'
          end
        else
          if((filled_qty > 0 && filled_qty < demand_qty))
            filled_state = 'P'
          elsif(filled_qty == 0 || filled_qty == nil || filled_qty == '')
            filled_state = 'E'
          else
            filled_state=''
          end
        end
      end
      filled_state
    end

    def convert_index_to_qty_for_wl(qty_index)
      case qty_index
        when '-3'
          return "WL"
        when '-2'
          return "S"
        when '-1'
          return "E"
        else
          return qty_index
      end
    end

    def check_approved_kit_and_update_accordingly(kit,kit_filling_id)
      kit_filling = Kitting::KitFilling.find_by_id(kit_filling_id)
      if kit.kit_media_type.kit_type ==  "multi-media-type"
        cup_parts = Kitting::CupPart.where(:cup_id => Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => kit.id).where(:commit_status => true).map(&:id)).map(&:id)).where(:commit_status => true, :status=> 1)
      else
        cup_parts = kit.cup_parts.where(:commit_status => 1,:status => 1)
      end
      kit_filling_details = Kitting::KitFilling.find_by_id(kit_filling_id).kit_filling_details
      kit_filling_histories_report = Kitting::KitFilling.find_by_id(kit_filling_id).kit_filling_history_reports
      intersection_result =  cup_parts.map{ |cp| cp.id} &  kit_filling_details.map { |kfd| kfd.cup_part_id }
      intersection_result_for_kit_filling_histories_report =  cup_parts.map{ |cp| cp.id} &  kit_filling_histories_report.map { |kfd| kfd.cup_part_id }

      total_result = cup_parts.map{ |cp| cp.id} |  kit_filling_details.map { |kfd| kfd.cup_part_id }
      total_result_for_kit_filling_histories_report = cup_parts.map{ |cp| cp.id} |  kit_filling_histories_report.map { |kfd| kfd.cup_part_id }

      delete_record_list = total_result-intersection_result
      delete_record_list_for_kit_filling_histories_report = total_result_for_kit_filling_histories_report-intersection_result_for_kit_filling_histories_report
      delete_record_list.each do |delete_record_no|
        @filling_record_to_delete = Kitting::KitFillingDetail.find_by_kit_filling_id_and_cup_part_id(kit_filling_id,delete_record_no)
        if @filling_record_to_delete.present?
          @filling_record_to_delete.destroy
        end
      end
      delete_record_list_for_kit_filling_histories_report.each do |delete_record_no|
        @filling_record_to_delete = Kitting::KitFillingHistoryReport.find_by_kit_filling_id_and_cup_part_id(kit_filling_id,delete_record_no)
        if @filling_record_to_delete.present?
          @filling_record_to_delete.destroy
        end
      end

      combined_result = (cup_parts.map{ |cp| cp.id if cp.in_contract}.compact &  kit_filling_details.map { |kfd| kfd.cup_part_id }) | cup_parts.map{ |cp| cp.id if cp.in_contract}.compact
      combined_result_for_kit_filling_histories_report = (cup_parts.map{ |cp| cp.id} &  kit_filling_histories_report.map { |kfd| kfd.cup_part_id }) | cup_parts.map{ |cp| cp.id}
      combined_result.each do |cup_part|
        @check_presence = Kitting::KitFillingDetail.find_by_kit_filling_id_and_cup_part_id(kit_filling_id,cup_part)
        if @check_presence.nil?
          @new_filling_detail = Kitting::KitFillingDetail.new(:kit_filling_id => kit_filling_id,:cup_part_id => cup_part,:filled_quantity =>0,:filled_state => "E")
          if @new_filling_detail.save
          else
            flash[:error] = "There is no such Part to Fill"
            redirect_to :back
          end
        end
      end
      combined_result_for_kit_filling_histories_report.each do |cup_part|
        cup_part_detail = Kitting::CupPart.where(:id => cup_part).try(:first)
        if cup_part_detail.present? && cup_part_detail.in_contract?
          @check_presence = Kitting::KitFillingHistoryReport.find_by_kit_filling_id_and_cup_part_id(kit_filling_id,cup_part)
          if @check_presence.nil?
            filling_histories_details = {:kit_number=> kit.try(:kit_number),:kit_copy_number=>kit_filling.try(:kit_copy).try(:kit_version_number),:customer_number=>kit_filling.try(:customer).try(:cust_no),:cup_no=>cup_part_detail.try(:cup).try(:cup_number),:part_number=>cup_part_detail.try(:part).try(:part_number),:demand_qty=>cup_part_detail.demand_quantity,:filled_qty=>"E",:filling_date=>kit_filling.created_at,:created_by=>kit_filling.try(:customer).try(:user_name),:kit_filling_id=>kit_filling.id,:cup_part_id=>cup_part_detail.id,:cup_part_status=>cup_part_detail.status,:cup_part_commit_status=>cup_part_detail.commit_status,:kit_work_order_id => kit_filling.try(:kit_work_order).try(:id)}
            @new_filling_detail = Kitting::KitFillingHistoryReport.new(filling_histories_details)
            @new_filling_detail.save
          end
        end
      end
    end
    #-------------Find Kit Filled State--------------------
    def find_kit_current_filled_state(kit_filling)
      filling_arr = Array.new
      kit_filling.kit_filling_details.each do |kit_details|
        filling_arr << kit_details.filled_state
      end
      if filling_arr.include?('P')
        filling_state = 2
      elsif filling_arr.uniq.count > 1
        filling_state = 2
      elsif ((filling_arr.uniq.count == 1 && filling_arr.include?('F')))
        filling_state = 1
      elsif ((filling_arr.uniq.count == 1 && filling_arr.include?('E')))
        filling_state = 0
      end
      return filling_state
    end
    #--------------------------------------------------------

    def get_commited_data
      commited_result = Proc.new { |object,key| object.map { |obj| obj.send(key.to_sym).where(:status => true,:commit_id => nil,:commit_status => true) } }
    end
  end
end
