require_dependency "kitting/application_controller"

module Kitting
  class CupPartsController < ApplicationController
#		before_filter :get_acess_right

##
# This action is called by an Ajax Function after a part is validated from the part search RBO,
# it creates and entry in the CupParts table for adding a part to a kit. Trasaction management of a kit is also
# maintained
##
    def create
      cup_id=params[:cup_id]
      cup_ref_id = params[:cup_ref_id]
      #@binder_kit_id = Kitting::Kit.find_by_commit_id(params[:kit_id])
      #if @binder_kit_id.present?
      if params[:mmt_kit_id].present?
        kit_id = params[:mmt_kit_id]
      else
        curr_kit = Kitting::Kit.find_by_id(params[:kit_id])
        if curr_kit.kit_media_type.kit_type == "multi-media-type"
          multi_kits = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(params[:kit_id],0).sort
          if multi_kits && multi_kits.first.kit_media_type.kit_type == "binder"
            kit_id = multi_kits.first.id
          else
            kit_id = params[:kit_id]
          end
        else
          kit_id = params[:kit_id]
        end
      end
      @binder_kit=Kitting::Kit.find_by_id(kit_id)
      if @binder_kit.kit_media_type.kit_type == "binder"
        @cup = @binder_kit.cups.create(:commit_status => false, :cup_number => params[:cup_number_sleev].to_i, :status => true)
        cup_id = @cup.id
        cup_ref_id =@cup.id
      end
      # end binder Kit
      @part = Kitting::Part.find_by_part_number(params[:part_number_auto].upcase)
      @cup_part_details = Kitting::CupPart.where(:cup_id => cup_id, :part_id => @part.id)

      if @cup_part_details[0]
        params[:commit] == 'Update'
      end

      if params[:commit] == 'Add' || params[:commit] == 'Add & Next' || @binder_kit.present?
        #@binder_kit_id = Kitting::Kit.find_by_commit_id(params[:kit_id])
        #if @binder_kit_id.present?
        @binder_kit=Kitting::Kit.find_by_id(params[:kit_id])
        if @binder_kit.kit_media_type.kit_type == "binder"
          @cup = @binder_kit.cups.create(:commit_status => false, :cup_number => params[:cup_number_sleev].to_i, :status => true)
          cup_id = @cup.id
          cup_ref_id =@cup.id
        end
        @cup = Kitting::Cup.find_by_id(cup_ref_id)

        if @cup.present?
          @cup_commit_status = @cup.commit_status
          if @cup_commit_status == true
            if Kitting::Cup.find_by_commit_id(cup_ref_id).blank?
              @dup_cup = @cup.dup
              @dup_cup.commit_id = @cup.id
              @dup_cup.commit_status = false
              @dup_cup.save(:validate => false)
              @dup_cup.update_attributes(params[:cup])
            else
              @cup= Kitting::Cup.find_by_commit_id(cup_ref_id).update_attributes(params[:cup],:commit_status => false)
            end

            if params[:part_number_auto].blank?
              flash[:notice] = "Invalid Part Number"
              redirect_to :back
            else
              # Find Part and Create a Duplicate Part !!!

              if @cup_part_details.blank?
                if params[:non_contract_part_check] && params[:non_contract_part_check] == "on"
                  nc_part = @part.cup_parts.create(:uom => params[:uom],:demand_quantity => params[:demand_quantity],:cup_id => cup_id,:commit_status => false)
                  nc_part.update_attribute("in_contract",false)
                else
                  @part.cup_parts.create(:uom => params[:uom],:demand_quantity => params[:demand_quantity],:cup_id => cup_id,:commit_status => false)
                end
              else
                if params[:non_contract_part_check] && params[:non_contract_part_check] == "on"
                  nc_part = @part.cup_parts.create(:uom => params[:uom],:demand_quantity => params[:demand_quantity],:cup_id => cup_id,:commit_status => false,:commit_id =>@cup_part_details[0].id)
                  nc_part.update_attribute("in_contract",false)
                else
                  @part.cup_parts.create(:uom => params[:uom],:demand_quantity => params[:demand_quantity],:cup_id => cup_id,:commit_status => false,:commit_id =>@cup_part_details[0].id )
                end
              end
              @kit_commit_id = Kitting::Kit.find_by_commit_id(params[:kit_id])
              if @kit_commit_id.present?
                @kit_commit_id.update_attribute("status",2)
              else
                @check_kit_status = Kitting::Kit.where(:id => params[:kit_id],:commit_status => true)
                if @check_kit_status.present?
                  @kit= Kit.find(params[:kit_id])
                  @duplicate_kit = @kit.dup
                  @duplicate_kit.commit_status = false
                  @duplicate_kit.commit_id = @kit.id
                  @duplicate_kit.status = 2
                  @duplicate_kit.updated_by= current_customer.id
                  @duplicate_kit.save(:validate => false)
                else
                  @kit = Kitting::Kit.find_by_id_and_commit_status(params[:kit_id],false)
                  @kit.status = 2
                  @kit.commit_status = false
                  @kit.updated_by= current_customer.id
                  @kit.save(:validate => false)
                end
              end
              @kit = Kit.find(params[:kit_id])
              # start binder Kit
              @binder_kit= Kit.find(kit_id)
              if @binder_kit.kit_media_type.kit_type == "binder"
                @message = 'Part was successfully added to draft.'
              else
                @message = 'Cup part was successfully added to draft.'
              end
              # end binder Kit
                respond_to do |format|
                  flash[:success] = @message
                  format.html  { redirect_to kits_detail_design_path(:cup_number => params[:cup_number],:kit_id => @kit.id,
                                                                     kit_number: @kit.kit_number, kit_media_type: @kit.kit_media_type.name, compartments: @kit.kit_media_type.compartment,
                                                                     compartment_layout: @kit.kit_media_type.compartment_layout, kit_id: @kit.id, bincenter: @kit.bincenter, :commit_status => @kit.commit_status,mmt_kit_id: kit_id ) }
                  @cup = Kitting::Cup.find_by_id(params[:cup_id]) unless Kit.find_by_id(kit_id).kit_media_type.kit_type == "binder"
                  format.js {}
                end
              # end
            end

          else
            Kitting::Cup.where(:id => cup_ref_id,:commit_status =>false).first.update_attributes(params[:cup],:commit_status =>false)
            unless params[:part_number_auto].blank?
              # @part = Kitting::Part.where(:part_number => params[:part_number_auto].upcase).first
              @part.update_attributes(number: params[:part_number_auto].upcase, description: params[:description])
              # @cup_part_details = Kitting::CupPart.where(:cup_id => cup_id, :part_id => @part.id)
              if @cup_part_details[0].blank?
                if params[:non_contract_part_check] && params[:non_contract_part_check] == "on"
                  nc_part = @part.cup_parts.create(:uom => params[:uom],:demand_quantity => params[:demand_quantity], :cup_id => cup_id,:commit_status => false)
                  nc_part.update_attribute("in_contract",false)
                else
                  @part.cup_parts.create(:uom => params[:uom],:demand_quantity => params[:demand_quantity], :cup_id => cup_id,:commit_status => false)
                end
              else
                @check_cup_part_details = Kitting::CupPart.where(:cup_id => cup_id, :part_id => @part.id,:commit_id => @cup_part_details.first.id)
                if @check_cup_part_details.blank?
                  if params[:non_contract_part_check] && params[:non_contract_part_check] == "on"
                    @cup_part_details[0].update_attributes(:uom => params[:uom],:demand_quantity => params[:demand_quantity],:cup_id => cup_id, :status => 1, :commit_status => false, :in_contract => false)
                  else
                    @cup_part_details[0].update_attributes(:uom => params[:uom],:demand_quantity => params[:demand_quantity],:cup_id => cup_id, :status => 1, :commit_status => false )
                  end
                else
                  if params[:non_contract_part_check] && params[:non_contract_part_check] == "on"
                    @cup_part_details[0].update_attributes(:uom => params[:uom],:demand_quantity => params[:demand_quantity],:cup_id => cup_id, :status => 1, :commit_status => false, :in_contract => false )
                  else
                    @cup_part_details[0].update_attributes(:uom => params[:uom],:demand_quantity => params[:demand_quantity],:cup_id => cup_id, :status => 1, :commit_status => false )
                  end
                end
              end
              @kit_commit_id = Kitting::Kit.find_by_commit_id(params[:kit_id])
              if @kit_commit_id.present?
                @kit_commit_id.update_attribute("status",2)
              else
                @check_kit_status = Kitting::Kit.where(:id => params[:kit_id],:commit_status => true)
                if @check_kit_status.present?
                  @kit= Kit.find(params[:kit_id])
                  @duplicate_kit = @kit.dup
                  @duplicate_kit.commit_status = false
                  @duplicate_kit.commit_id = @kit.id
                  @duplicate_kit.status = 2
                  @duplicate_kit.updated_by= current_customer.id
                  @duplicate_kit.save(:validate => false)
                else
                  @kit = Kitting::Kit.find_by_id_and_commit_status(params[:kit_id],false)
                  @kit.status = 2
                  @kit.commit_status = false
                  @kit.updated_by= current_customer.id
                  @kit.save(:validate => false)
                end
              end
              @kit = Kit.find(params[:kit_id])
              # start binder Kit
              @binder_kit= Kit.find_by_id(kit_id)
              if @binder_kit.kit_media_type.kit_type == "binder"
                @message = 'Part was successfully added to drafts .'
              else
                @message = 'Cup part was successfully added to drafts.'
              end
              # end binder Kit
                respond_to do |format|
                  flash[:success] = @message
                  format.html  { redirect_to kits_detail_design_path(:cup_number => params[:cup_number],:kit_id => @kit.id,
                                                                     kit_number: @kit.kit_number, kit_media_type: @kit.kit_media_type.name, compartments: @kit.kit_media_type.compartment,
                                                                     compartment_layout: @kit.kit_media_type.compartment_layout, kit_id: @kit.id, bincenter: @kit.bincenter, :commit_status => @kit.commit_status,mmt_kit_id: kit_id ) }

                  @cup = Kitting::Cup.find_by_id(params[:cup_id]) unless Kit.find_by_id(kit_id).kit_media_type.kit_type == "binder"
                  format.js {}
                end
              # end
            else
              flash[:notice] = "Invalid Part Number"
              redirect_to :back
            end
          end
        else
          flash[:error] = "The Kit you are trying to design is either Reset/Approved by Administrator."
          redirect_to kits_path
        end

      elsif params[:commit] == 'Update'
        if params[:part_number_auto].present?
          @cup_id = params[:cup_id]
          # @part_details = Kitting::Part.find_by_part_number(params[:part_number_auto].strip)
          @part_id= @part.id
          @cup_part_details = @cup_part_details.first
          @cup_part_details_commit_status = Kitting::CupPart.where(:cup_id => @cup_id, :part_id => @part_id, :commit_status => false).first
          unless @cup_part_details.demand_quantity == params[:demand_quantity]
            if @cup_part_details_commit_status.present?
              @cup_part_details_commit_status.update_attributes(:demand_quantity => params[:demand_quantity])
            else
              @dup_cup_part = Kitting::CupPart.new(:uom => @cup_part_details.uom,:cup_id => @cup_id , :demand_quantity => params[:demand_quantity],:part_id => @part_id, :commit_status => false,:commit_id =>@cup_part_details.id )
              @dup_cup_part.save(:validate => false )
            end
            @kit_commit_id = Kitting::Kit.find_by_commit_id(params[:kit_id])
            if @kit_commit_id.present?
              @kit_commit_id.update_attribute("status",2)
            else
              @check_kit_status = Kitting::Kit.where(:id => params[:kit_id],:commit_status => true)
              if @check_kit_status.present?
                @kit= Kit.find(params[:kit_id])
                @duplicate_kit = @kit.dup
                @duplicate_kit.commit_status = false
                @duplicate_kit.commit_id = @kit.id
                @duplicate_kit.status = 2
                @duplicate_kit.updated_by= current_customer.id
                @duplicate_kit.save(:validate => false)
              else
                @kit = Kitting::Kit.find_by_id_and_commit_status(params[:kit_id],false)
                @kit.status = 2
                @kit.commit_status = false
                @kit.updated_by= current_customer.id
                @kit.save(:validate => false)
              end
            end
          end
          respond_to do |format|
            @cup = Kitting::Cup.find_by_id(params[:cup_id])
            format.js {}
          end
        end
      end
    end

    ##
    # This action is for updating quantity of a part in a kit. After updating the quantity of part. That kit is send
    # to approval
    ##
    def update_quantity

      if params[:part_number_for_delete].present?
        params[:part_number_for_delete].each_with_index do |part_number, index|
          unless params[:Quantities][index] == params[:old_quantities][index]
            part_number = part_number.strip
            @cup_id = params[:cup_id_for_delete][index]
            @part_details = Kitting::Part.find_by_part_number(part_number)
            @part_id= @part_details.id
            @cup_part_details = Kitting::CupPart.where(:cup_id => params[:cup_id_for_delete][index], :part_id => @part_id)
            @cup_part_details_commit_status = Kitting::CupPart.where(:cup_id => params[:cup_id_for_delete][index], :part_id => @part_id, :commit_status => false)
            if @cup_part_details_commit_status.present?
              @cup_part_details_commit_status[0].update_attributes(:demand_quantity => params[:Quantities][index])
            else
              @dup_cup_part = Kitting::CupPart.new(:uom => @cup_part_details[0].uom,:cup_id => params[:cup_id_for_delete][index], :demand_quantity => params[:Quantities][index],:part_id => @part_id, :commit_status => false,:commit_id =>@cup_part_details[0].id )
              @dup_cup_part.save(:validate => false )
            end
            @kit_commit_id = Kitting::Kit.find_by_commit_id(params[:kit_id])
            if @kit_commit_id.present?
              @kit_commit_id.update_attribute("status",2)
            else
              @check_kit_status = Kitting::Kit.where(:id => params[:kit_id],:commit_status => true)
              if @check_kit_status.present?
                @kit= Kit.find(params[:kit_id])
                @duplicate_kit = @kit.dup
                @duplicate_kit.commit_status = false
                @duplicate_kit.commit_id = @kit.id
                @duplicate_kit.status = 2
                @duplicate_kit.updated_by= current_customer.id
                @duplicate_kit.save(:validate => false)
              else
                @kit = Kitting::Kit.find_by_id_and_commit_status(params[:kit_id],false)
                @kit.status = 2
                @kit.commit_status = false
                @kit.updated_by= current_customer.id
                @kit.save(:validate => false)
              end
            end
          end
        end
      end
      redirect_to :back
    end

    def add_parts_for_binder
      if params[:mmt_kit_id].present?
        kit_id = params[:mmt_kit_id]
      else
        current_kit=Kitting::Kit.find_by_id(params[:kit_id])
        if current_kit.kit_media_type.kit_type == "multi-media-type"
          multi_kits = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(params[:kit_id],0).sort
          if multi_kits && multi_kits.first.kit_media_type.kit_type == "binder"
            kit_id = multi_kits.first.id
          else
            kit_id = params[:kit_id]
          end
        else
          kit_id = params[:kit_id]
        end
      end
      binder_kit=Kitting::Kit.find_by_id(kit_id)
      if binder_kit.present?
        if params[:part_numbers].present?
          all_parts = params[:part_numbers]
          all_qty = params[:quantities]
          all_uoms = params[:uoms]
          non_contract_statuses = params[:nc_status]
          tray_nos = params[:tray_nos]
          all_parts.each_with_index do |part_number,index|
            cup_number = tray_nos[index].to_i
            binder_cup = binder_kit.cups.create(:commit_status => false, :cup_number => cup_number, :status => true)
            cup_id = binder_cup.id
            cup_ref_id = binder_cup.id
            cup = binder_cup
            part = Kitting::Part.find_by_part_number(part_number.upcase)
            cup_part = part.cup_parts.create(:uom => all_uoms[index],:demand_quantity => all_qty[index].upcase,:cup_id => cup_id,:commit_status => false)
            if non_contract_statuses[index] == "true"
              cup_part.update_attribute("in_contract",false)
            end
          end
        end
        @kit_commit_id = Kitting::Kit.find_by_commit_id(params[:kit_id])
        if @kit_commit_id.present?
          @kit_commit_id.update_attribute("status",2)
        else
          @check_kit_status = Kitting::Kit.where(:id => params[:kit_id],:commit_status => true)
          if @check_kit_status.present?
            @kit= Kit.find(params[:kit_id])
            @duplicate_kit = @kit.dup
            @duplicate_kit.commit_status = false
            @duplicate_kit.commit_id = @kit.id
            @duplicate_kit.status = 2
            @duplicate_kit.updated_by= current_customer.id
            @duplicate_kit.save(:validate => false)
          else
            @kit = Kitting::Kit.find_by_id_and_commit_status(params[:kit_id],false)
            @kit.status = 2
            @kit.commit_status = false
            @kit.updated_by= current_customer.id
            @kit.save(:validate => false)
          end
        end
        respond_to do |format|
          format.js {}
        end
      end
    end
  end
end