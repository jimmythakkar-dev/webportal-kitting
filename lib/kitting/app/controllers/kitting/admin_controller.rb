require_dependency "kitting/application_controller"
# Administration Controller for Kitting
module Kitting
  class AdminController < ApplicationController
    layout "kitting/fit_to_compartment", :only => [:cust_configs]
    # Lists accessible modules for customizing Application [Part Customization,Location Setup,Kit-Media Type,Change Kit-Media Type,Delete Kit Copies,Replace Part]
    def index
      if can?(:>=, "5")
      else
        redirect_to main_app.unauthorized_url
      end
    end

    # Method to Customize part images and part cup_count
    def cust_configs
      # if session[:acct_switch].include?("026565") || session[:acct_switch].include?("26565")
      #   @binCenters = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
      # end
    end

    # Method to allow multiple parts per cup to Kit
    def allow_customer_specific_changes
      cust_no_arr = session[:account_switcher_array].map { |session_data| session_data.scan(/\d+/).first }
      cust_name_arr = session[:account_switcher_array].map { |session_data|  session_data.split(session_data.scan(/\d+/).first).last.gsub(/[[:space:]]/, ' ').strip }
      customer_records = Hash[cust_no_arr.zip(cust_name_arr)]
      bin_center_list = get_default_bin_center("default_kit_bin_center")
      part_bin_center_list = get_default_bin_center("default_part_bin_center")
      crib_part_bin_center_list = get_default_bin_center("default_crib_part_bin_center")
      kitting_type_list = get_default_bin_center("kitting_type")
      customer_records.each do |cust_no,cust_name|
        customer = Kitting::CustomerConfigurations.find_or_create_by_cust_no(cust_no: cust_no)
        customer.update_attributes(:cust_name =>cust_name,:updated_by => current_customer.id,:non_contract_part => check_config("non_contract_check",cust_no),:multiple_part => check_config("multiple_part",cust_no),:prevent_kit_copy => check_config("prevent_kit_copy",cust_no), :default_kit_bin_center => set_default_bin_center(bin_center_list,cust_no), :default_part_bin_center => set_default_bin_center(part_bin_center_list,cust_no), :default_crib_part_bin_center => set_default_bin_center(crib_part_bin_center_list,cust_no), :kitting_type => set_default_bin_center(kitting_type_list,cust_no), :invoicing_required => check_config("invoicing_required",cust_no))
        @error = "ERROR WHILE SAVING RECORD" unless customer.save
      end
      if @error.present?
        flash[:error] = "ERROR WHILE UPDATING RECORDS."
      else
        flash[:notice] = "Successfully Updated the Changes"
      end
      redirect_to :back
    end

    ## Method to allow editing kit description
    def edit_kit_description
      if can?(:>=, "5")
        params[:page] = params[:page].nil? ? 1 : params[:page]
        if params[:kit_number_edit].present?
          @kits= Kitting::Kit.where("status in (?) and cust_no = ? and kit_number LIKE ?  and commit_id is null and current_version != ? and category is null",
                                    [1,2], current_user, "%" + params[:kit_number_edit].upcase.try(:strip) +"%" , 0).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
          if @kits.blank?
            flash.now[:error] = "Kit not found"
          end
        else
          @kits= Kitting::Kit.where("status in (?) and cust_no = ? and  commit_id is null and current_version != ? and category is null",
                                    [1,2], current_user, 0).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##Send Edited description to cardex calling the kit approval rbo and also update the database with the updated description.
    def send_kit_description
      if can?(:>=, "5")
        params[:new_desc] = params[:new_desc].strip rescue nil
        if params[:new_desc].present?
          if params[:kit_id] && params[:kit_number]
            kit_to_edit = Kitting::Kit.where(:kit_number => params[:kit_number],:commit_id => nil)
            updated_kit = Kitting::Kit.where(:kit_number => params[:kit_number],:commit_status =>false).first
            if kit_to_edit.present?
              kit_to_edit = kit_to_edit.first
            end
            if kit_to_edit.present?
              if kit_to_edit.kit_media_type.kit_type == "multi-media-type"
                misc_arr= Array.new;parts_arr=Array.new;quantity_arr=Array.new ;uom_arr=Array.new;in_contract_arr=Array.new
                kit_mmt_kits = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(kit_to_edit.id, false).sort
                kit_mmt_kits.each_with_index do |orig_kit, index|
                  mmt_kit_details = Kitting::Kit.get_kit_data(orig_kit,"multi-media-type",index)
                  misc_arr.push(*mmt_kit_details[:misc])
                  parts_arr.push(*mmt_kit_details[:parts])
                  quantity_arr.push(*mmt_kit_details[:quantity])
                  uom_arr.push(*mmt_kit_details[:uom])
                  in_contract_arr.push(*mmt_kit_details[:in_contract_status])
                end
                kit_details = { :misc =>misc_arr,:parts=>parts_arr,:quantity => quantity_arr, :uom=> uom_arr, :in_contract_status =>in_contract_arr }
              else
                kit_details = Kitting::Kit.get_kit_data(kit_to_edit)
              end
              if updated_kit.present?
                kit_to_edit.update_attribute("description", params[:new_desc])
                updated_kit.update_attribute("description", params[:new_desc])
                flash[:success] = "Description Updated Successfully For #{params[:kit_number]}"
                redirect_to :back
              else
                if kit_details[:parts].present?
                  contract_parts = []
                  contract_misc = []
                  contract_quantity = []
                  contract_uom = []
                  kit_details[:in_contract_status].each_with_index do |contract_status,index|
                    if contract_status
                      contract_parts << kit_details[:parts][index]
                      contract_misc << kit_details[:misc][index]
                      contract_quantity << kit_details[:quantity][index]
                      contract_uom << kit_details[:uom][index]
                    end
                  end
                end
                check_kit =  invoke_webservice method: "get", action: "kitting", query_string: { action: "I",custNo: current_user,kitStatuses: "1,2",kitNo: params[:kit_number].upcase }
                if check_kit && check_kit["errMsg"].blank?
                  @response = invoke_webservice method: 'post',action: 'kitting',
                                                data: {
                                                    action:    "M",
                                                    custNo:    current_user,
                                                    user:      session[:user_name],
                                                    kitNo:     kit_to_edit.kit_number.upcase,
                                                    kitStatus: "1",
                                                    kitLoc:    kit_to_edit.bincenter,
                                                    partNo:    contract_parts,
                                                    um:        contract_uom,
                                                    misc1:     contract_misc,
                                                    qty:       contract_quantity,
                                                    kitVer:    "001",
                                                    kitDesc:   params[:new_desc],
                                                    kitNotes:  [kit_to_edit.notes.nil? ? "" : kit_to_edit.notes ]
                                                }
                  if @response.present? && @response["errCode"]=="0"
                    kit_to_edit.update_attribute("description", params[:new_desc])
                    flash[:success] = "Description Updated Successfully For #{params[:kit_number]}"
                    redirect_to :back
                  else
                    err_msg = @response["errMsg"] if @response
                    flash[:error] = err_msg  || 'Service Temporarily Unavailable'
                    redirect_to :back
                  end
                else
                  err_msg = check_kit["errMsg"] if check_kit
                  flash[:error] = err_msg || 'Service Temporarily Unavailable'
                  redirect_to :back
                end
              end
            else
              flash[:error] = 'Kit Not Found'
              redirect_to :back
            end
          else
            flash[:error] = 'Kit Not Found'
            redirect_to :back
          end
        else
          flash[:error] = 'Kit Not Found'
          redirect_to :back
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ## Method to activate/deactivate kits
    def change_kit_status
      if can?(:>=, "5")
        if params[:kit_number].present? && params[:kit_id].blank?
          drafted_kits = Kitting::Kit.where("status = ? and commit_status = ? and commit_id is not null and parent_kit_id is null and customer_id IN (?) and category is null",2,0, current_company)
          drafted_ids = drafted_kits.map(&:commit_id) unless drafted_kits.blank?
          if drafted_ids.present?
            @kit_change_status = Kitting::Kit.where("kit_number LIKE ? and commit_status = 1 and parent_kit_id is null and customer_id IN (?) and id not in (?) and category is null", "%#{params[:kit_number].upcase}%",current_company, drafted_ids).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
          else
            @kit_change_status = Kitting::Kit.where("kit_number LIKE ? and commit_status = 1 and parent_kit_id is null and customer_id IN (?) and category is null", "%#{params[:kit_number].upcase}%",current_company).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
          end
        elsif params[:kit_number].blank? && params[:kit_id].blank?
          @kit_change_status = Kitting::Kit.where("commit_status = 1 and parent_kit_id is null and customer_id IN (?) and category is null", current_company).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
        elsif params[:kit_number].blank? && params[:kit_id].present?
          @kit_copies = Kitting::KitCopy.where(:kit_id => params[:kit_id])
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    def submit_kit_status
      if can?(:>=, "5")
        if params[:commit] == "Update Kit Status"
          count_flag = 0
          if session[:checked_kit_ids].present?
            session[:checked_kit_ids].each do |kit_id|
              @kit_to_deactivate = Kitting::Kit.where(:id => kit_id)
              @kit_copies_to_deactivate = @kit_to_deactivate.first.kit_copies unless @kit_to_deactivate.blank?
              if @kit_copies_to_deactivate.present?
                @kit_to_deactivate.first.update_attribute('status',6)
                @kit_copies_to_deactivate.each do |kit_copy|
                  kit_copy.update_attribute('status',6) unless kit_copy.blank?
                  kit_copy.kit_status_details.create(:kit_id => kit_id, :updated_by => current_customer.user_name, :reason => params[:reason])
                  count_flag = 1
                end
              else
                @kit_to_deactivate.first.update_attribute('status',6) unless @kit_to_deactivate.blank?
                @kit_to_deactivate.first.kit_status_details.create(:updated_by => current_customer.user_name, :reason => params[:reason]) unless @kit_to_deactivate.blank?
                count_flag = 1
              end
            end
          end
          if session[:unchecked_kit_ids].present?
            session[:unchecked_kit_ids].each do |kit_id|
              @kit_to_activate = Kitting::Kit.where(:id => kit_id)
              @kit_copies_to_activate = @kit_to_activate.first.kit_copies unless @kit_to_activate.blank?
              if @kit_copies_to_activate.present?
                @kit_to_activate.first.update_attribute('status',1)
                @kit_copies_to_activate.each do |kit_copy|
                  kit_copy.update_attribute('status',1) unless kit_copy.blank?
                  kit_copy.kit_status_details.create(:kit_id => kit_id, :updated_by => current_customer.user_name, :reason => params[:reason])
                  count_flag = 1
                end
              else
                @kit_to_activate.first.update_attribute('status',1) unless @kit_to_activate.blank?
                @kit_to_activate.first.kit_status_details.create(:updated_by => current_customer.user_name, :reason => params[:reason]) unless @kit_to_activate.blank?
                count_flag = 1
              end
            end
          end
          session.delete(:checked_kit_ids)
          session.delete(:unchecked_kit_ids)
          flash[:notice] = "Successfully Updated Kit Status/Statuses" if count_flag == 1
          redirect_to :back
        elsif params[:commit] == "Update Copy Status"
          count = 0
          if session[:checked_kit_copy_ids].present? || session[:unchecked_kit_copy_ids].present?
            if session[:checked_kit_copy_ids].present?
              kit_copy_id = session[:checked_kit_copy_ids].first
              kit_status = Kitting::KitCopy.where(:id => kit_copy_id).first.kit.status rescue 6
            else
              kit_copy_id = session[:unchecked_kit_copy_ids].first
              kit_status = Kitting::KitCopy.where(:id => kit_copy_id).first.kit.status rescue 6
            end
          end
          unless kit_status == 6
            if session[:checked_kit_copy_ids].present?
              session[:checked_kit_copy_ids].each do |kit_copy_id|
                @kit_copy_to_deactivate = Kitting::KitCopy.where(:id => kit_copy_id)
                if @kit_copy_to_deactivate.present?
                  @kit_copy_to_deactivate.first.update_attribute('status',6)
                  @kit_copy_to_deactivate.first.kit_status_details.create(:updated_by => current_customer.user_name, :reason => params[:reason]) unless @kit_copy_to_deactivate.blank?
                  count = 1
                end
              end
            end
            if session[:unchecked_kit_copy_ids].present?
              session[:unchecked_kit_copy_ids].each do |kit_copy_id|
                @kit_copy_to_activate = Kitting::KitCopy.where(:id => kit_copy_id)
                if @kit_copy_to_activate.present?
                  @kit_copy_to_activate.first.update_attribute('status',1)
                  @kit_copy_to_activate.first.kit_status_details.create(:updated_by => current_customer.user_name, :reason => params[:reason]) unless @kit_copy_to_activate.blank?
                  count = 1
                end
              end
            end
          end
          session.delete(:checked_kit_copy_ids)
          session.delete(:unchecked_kit_copy_ids)
          if kit_status == 6
            flash[:alert] = "Can't Activate/Deactivate a Copy as the Kit is inactive."
          else
            flash[:notice] = "Successfully Updated KitCopy Status/Statuses" if count == 1
          end
          redirect_to :back
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    def store_inactive_checked_status
      if params[:kit_copy_id].present? && params[:copy_checked].present?
        session[:checked_kit_copy_ids] ||= []
        session[:unchecked_kit_copy_ids] ||= []
        params[:kit_copy_id] = params[:kit_copy_id].to_i
        if params[:copy_checked] == "true"
          session[:unchecked_kit_copy_ids].delete(params[:kit_copy_id]) if session[:unchecked_kit_copy_ids].include?(params[:kit_copy_id])
          session[:checked_kit_copy_ids] << params[:kit_copy_id] unless session[:checked_kit_copy_ids].include?(params[:kit_copy_id])
        else
          session[:checked_kit_copy_ids].delete(params[:kit_copy_id]) if session[:checked_kit_copy_ids].include?(params[:kit_copy_id])
          session[:unchecked_kit_copy_ids] << params[:kit_copy_id] unless session[:unchecked_kit_copy_ids].include?(params[:kit_copy_id])
        end
        render :json => {"status" => "Success"}
      else
        session[:checked_kit_ids] ||= []
        session[:unchecked_kit_ids] ||= []
        params[:kit_id] = params[:kit_id].to_i
        if params[:checked] == "true"
          session[:unchecked_kit_ids].delete(params[:kit_id]) if session[:unchecked_kit_ids].include?(params[:kit_id])
          session[:checked_kit_ids] << params[:kit_id] unless session[:checked_kit_ids].include?(params[:kit_id])
        else
          session[:checked_kit_ids].delete(params[:kit_id]) if session[:checked_kit_ids].include?(params[:kit_id])
          session[:unchecked_kit_ids] << params[:kit_id] unless session[:unchecked_kit_ids].include?(params[:kit_id])
        end
        render :json => {"status" => "Success"}
      end
    end

    private
    # Check if params is present and check if account number is present in params to check status true else false
    def check_config config_type, cust_no
      if params[config_type.to_sym].present?
        params[config_type.to_sym].include?(cust_no)
      else
        false
      end
    end
    def set_default_bin_center bin_list, cust_no
      if bin_list.present?
        bin_list[cust_no].first if bin_list.include?(cust_no)
      end
    end
    def get_default_bin_center bin_center
      if params[bin_center]
        params[bin_center].each do |cust,bin|
          unless bin.first.present?
            params[bin_center].delete(cust)
          end
        end
      end
    end
  end
end
