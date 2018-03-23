require_dependency "kitting/application_controller"

module Kitting
  class CupsController < ApplicationController
    #before_filter :get_acess_right

    # Builds Cup Details using a Ajax request during Kit Set Up
    def build
      @cup= Kitting::Cup.find(params[:cup_id])
      @dup_cup_status= Kitting::Cup.where(:commit_id => params[:cup_id])
      if @dup_cup_status.present?
        @cup= @dup_cup_status.first
      end
      respond_to do |format|
        format.js { }
      end
    end

    ##
    # This method is used for disabling a cup for a configurable kit. Its is called by an AJAX function.
    ##
    def disable_cup
      status_check = Array.new
      cups_id_arr = params[:cup_id].split(',')
      # ActiveRecord::Base.transaction do
      cups_id_arr.each do |cup_id|
        if cup_id.present?
          cup=Kitting::Cup.where(:id => cup_id).try(:first)
          if cup.present?
            ActiveRecord::Base.transaction do
              kit = cup.kit
              @cup_part_details = Kitting::CupPart.where(:cup_id => cup_id)
              # cup.update_attribute(:status, false)
              cup_part_details_commit_status = Kitting::CupPart.where(:cup_id => cup_id,:commit_status => false)
              if cup_part_details_commit_status.present?
                cup_part_details_commit_status.each do |cup_part|
                  cup_part.update_attribute("status",0) unless cup_part.blank?
                end
              else
                @cup_part_details.each do |cup_part|
                  dup_cup_part = Kitting::CupPart.new(:cup_id => cup_id, :part_id => cup_part.part_id,:status => 0,:commit_status => false,:commit_id => cup_part.id, :demand_quantity => cup_part.demand_quantity ) unless cup_part.blank?
                  dup_cup_part.save(:validate => false)
                end
              end
              @cup_commit_status = cup.commit_status if cup.present?
              if @cup_commit_status == true
                if Kitting::Cup.find_by_commit_id(cup_id).blank?
                  @dup_cup = cup.dup
                  @dup_cup.commit_id = cup.id
                  @dup_cup.commit_status = false
                  @dup_cup.status = false
                  @dup_cup.save(:validate => false)
                else
                  cup= Kitting::Cup.find_by_commit_id(cup_id).update_attributes(:status=>false,:commit_status => false)
                end
              else
                cup.update_attribute("status",false)
              end
              kit = kit.parent_kit_id ? Kitting::Kit.find_by_id(kit.parent_kit_id) : kit
              if kit.present?
                @kit_commit_id = Kitting::Kit.find_by_commit_id(kit.id)
                if @kit_commit_id.present?
                  @kit_commit_id.update_attribute("status",2)
                else
                  @check_kit_status = Kitting::Kit.where(:id => kit.id,:commit_status => true)
                  if @check_kit_status.present?
                    @kit= Kit.find(kit.id)
                    @duplicate_kit = @kit.dup
                    @duplicate_kit.commit_status = false
                    @duplicate_kit.commit_id = @kit.id
                    @duplicate_kit.status = 2
                    @duplicate_kit.updated_by= current_customer.id
                    @duplicate_kit.save(:validate => false)
                  else
                    @kit = Kitting::Kit.find_by_id_and_commit_status(kit.id,false)
                    @kit.status = 2
                    @kit.commit_status = false
                    @kit.updated_by= current_customer.id
                    @kit.save(:validate => false)
                  end
                end
              end
              status_check.push(true)
            end
          else
            status_check.push(false)
          end
        else
          status_check.push(false)
        end
      end
      # end
      if status_check.include? false
        render :json =>  { "status" => "Cup Not Found" }.to_json
      else
        render :json => { "status" => "Updated Commit Status for the removed cup" }.to_json
      end
    end

    def close_add_part_popup
    end

  end
end