require_dependency "kitting/application_controller"
module Kitting
  class KitsController < ApplicationController

    layout "kitting/fit_to_compartment", :only => [:edit,:detail_design, :show, :pick_ticket, :print_label ]

    before_filter :get_acess_right, :except => [:destroy,:delete_binder_kit_part,:index,:search,:delete_record,:kit_in_draft,:show,:new,:create,:detail_design,:part_look_up,:update,:update_cardex,:update_kit_details]
#    after_filter :delete_binder_kit_part, :only => [:delete_record]
    before_filter :add_headers, :only=>[ :download_sample,:csv_export ]

##
# This action is of index page of kits showing Kit list as per user access
##
    def index
      @kit_media_types = Kitting::KitMediaType.where("name = ? OR  customer_number = ?","--",current_user)
    end

##
# This action makes Bailment RBO Request after approving a kit and renders a pdf containing
#  the Bailment Info of that kit if the kit is present in Bailment.
##
    def bailment_info_print
      @kit = Kitting::Kit.find_by_kit_number_and_commit_id_and_category(params[:kit_number],nil,nil)
      if @kit
        @updated_by = Kitting::Customer.find(@kit.updated_by).user_name  rescue ""
      else
        @updated_by = ""
      end
      @bailment_info = invoke_webservice method: "get", action: "bailmentInfo", query_string: {custNo: current_user,partNo: params[:kit_number],approverName:session[:user_name],userName:@updated_by,level:session[:user_level],versionNo:params[:version],mailFlag:"N"}
      if @bailment_info.present?
        if @bailment_info["boxId"].present?
          respond_to do |format|
            format.html do
              render :pdf => "bailment_info_print.html.erb",
                     :header => { :right => '[page] of [topage]'},
                     :margin => {:top =>9, :bottom => 22, :left => 12, :right => 12 }
            end
          end
        end
      else
        render :text => "<script type=\"text/javascript\"> window.close(); </script>"
      end
    end

##
# This action is for searching kits by KitNumber, PartNumber, KitMediaType,
#  Location. If the kit is present in RBO but not in the DB, then on clicking on the kit number
# it gets created in the DB and its show page is displayed.
##
    def search
      params[:page] = params[:page].nil? ? 1 : params[:page]
      params[:kit_number_search] = params[:kit_number_search].try(:upcase)
      @filter_media_type = Kitting::KitMediaType.find(params["media_type_search"]) unless params["media_type_search"].blank?
      @kit_media_types = Kitting::KitMediaType.where("name = ? OR  customer_number = ?","--",current_user)
      if params[:rbo_result] == "true"
        if params[:kit_status].class == String
          params[:kit_status] = params[:kit_status].gsub(" ",",").split(",")
        end
        if params[:kit_number_search].include?("%")
          params[:kit_number_search] = params[:kit_number_search].gsub("%","")
        end
        @kitting_response = invoke_webservice method: 'get', action: 'kitting',	query_string: { action: params[:kit_search_type], custNo: current_user, kitStatuses: params[:kit_status].present? ? params[:kit_status].join(",") :"1,2", kitNo: params[:kit_number_search].try(:strip).try(:upcase), page: params[:page].to_s }
        if @kitting_response
          if @kitting_response["errCode"] == "0"
            @total_records = @kitting_response["totalRecords"].to_i
            @total_page = divide_records_in_pages @total_records
            @result = Array.new(@kitting_response["totalRecords"].to_i).paginate(params[:page],100) rescue "A Error Occured while pagination."
            render "search_result"
          else
            flash.now[:alert] = @kitting_response["errMsg"]
            render 'index'
          end
        else
          flash.now[:notice] = "Service temporary unavailable"
          render "index"
        end
      else
        @search = params[:kit_number_search]
        if @search.present?
          if @filter_media_type.present?
            if params[:kit_search_type] == "SL"
              @kits = Kitting::Kit.where("status IN (?) and bincenter = ? and customer_id IN (?) and parent_kit_id is null and category is null",params[:kit_status],params[:kit_number_search],current_company).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
            elsif params[:kit_search_type] == "SP"
              if @search.include?("%")
                fuzzy_search = @search.gsub("%","")
                @kits = Kitting::Kit.joins(:cups => [:cup_parts => :part]).where("part_number LIKE ? and kit_media_type_id = ? and kits.status IN (?) and kits.customer_id IN (?) and kits.parent_kit_id is null and category is null","#{fuzzy_search}%",params[:media_type_search],params[:kit_status],current_company).sort_by { |obj| obj.created_at }.paginate(params[:page], 100)
              elsif @search.include?("_")
                @kits = Kitting::Kit.joins(:cups => [:cup_parts => :part]).where("part_number LIKE ? and kit_media_type_id = ? and kits.status IN (?) and kits.customer_id IN (?) and kits.parent_kit_id is null and category is null",@search,params[:media_type_search],params[:kit_status],current_company).sort_by { |obj| obj.created_at }.paginate(params[:page], 100)
              else
                @kits = Kitting::Kit.joins(:cups => [:cup_parts => :part]).where("part_number = ? and kit_media_type_id = ? and kits.status IN (?) and kits.customer_id IN (?) and kits.parent_kit_id is null and category is null",@search,params[:media_type_search],params[:kit_status],current_company).sort_by { |obj| obj.created_at }.paginate(params[:page], 100)
              end
            else
              @kits =  Kitting::Kit.where("kit_number LIKE ? and status IN (?) and kit_media_type_id = ? and customer_id IN (?) and parent_kit_id is null and category is null","%#{@search}%",params[:kit_status],params[:media_type_search],current_company).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
            end
          else
            if params[:kit_search_type] == "SL"
              @kits = Kitting::Kit.where("status IN (?) and bincenter = ? and customer_id IN (?) and parent_kit_id is null and category is null",params[:kit_status],params[:kit_number_search],current_company).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
            elsif params[:kit_search_type] == "SP"
              if @search.include?("%")
                fuzzy_search = @search.gsub("%","")
                @kits = Kitting::Kit.joins(:cups => [:cup_parts => :part]).where("part_number LIKE ?  and kits.status IN (?) and kits.customer_id IN (?) and kits.parent_kit_id is null and category is null","#{fuzzy_search}%",params[:kit_status],current_company).sort_by { |obj| obj.created_at }.paginate(params[:page], 100)
                if @kits.blank?
                  params[:rbo_search] = "true"
                end
              elsif @search.include?("_")
                @kits = Kitting::Kit.joins(:cups => [:cup_parts => :part]).where("part_number LIKE ?  and kits.status IN (?) and kits.customer_id IN (?) and kits.parent_kit_id is null and category is null",@search,params[:kit_status],current_company).sort_by { |obj| obj.created_at }.paginate(params[:page], 100)
                if @kits.blank?
                  params[:rbo_search] = "true"
                end
              else
                @kits = Kitting::Kit.joins(:cups => [:cup_parts => :part]).where("part_number = ?  and kits.status IN (?) and kits.customer_id IN (?) and kits.parent_kit_id is null and category is null",params[:kit_number_search],params[:kit_status],current_company).sort_by { |obj| obj.created_at }.paginate(params[:page], 100)
                if @kits.blank?
                  params[:rbo_search] = "true"
                end
              end
            else
              @kits =  Kitting::Kit.where("kit_number LIKE ? and status IN (?) and customer_id IN (?) and parent_kit_id is null and category is null","%#{@search}%",params[:kit_status],current_company).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
            end
          end
        else
          if @filter_media_type.present?
            @kits = Kitting::Kit.where("status IN (?) and kit_media_type_id = ? and customer_id IN (?) and parent_kit_id is null and category is null",params[:kit_status],params[:media_type_search],current_company).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
          else
            @kits = Kitting::Kit.where("status IN (?)  and customer_id IN (?) and parent_kit_id is null and category is null",params[:kit_status],current_company).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
          end
        end
        render "search_result"
      end
    end

##
# This action is for listing all kits that in draft and are or not approved.
##
    def kit_in_draft
      if can?(:>=,"3")
        @kits = Kitting::Kit.where(:status =>2,:commit_status => false,:customer_id => current_company, parent_kit_id: nil,category: nil).paginate(:page => params[:page], :per_page => 100).order('created_at desc')
      elsif can?(:>,"3")
        Kitting::Kit.where(:status =>2,:commit_status => false,:customer_id => current_company, parent_kit_id: nil,category: nil).paginate(:page => params[:page], :per_page => 100).order('created_at desc')
      else
        redirect_to  main_app.unauthorized_url
      end
    end

##
# This action is for listing all kits that yet to be approved or
# are edited after approval and hence need to be reapproved.
##
    def kits_approval
      if can?(:>,"4")
        @binCenters_response = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
        @binCenters = @binCenters_response.nil? ? [] : @binCenters_response['binCenterList']
        if params[:kit_number_search].present?
          @kits= Kitting::Kit.where("parent_kit_id IS NULL and status = ? and edit_status = ? and cust_no = ? and kit_number LIKE ? and category is null", 2, "FK" ,current_user, "%" + params[:kit_number_search].upcase.try(:strip) +"%")
          if @kits.blank?
            flash.now[:message] = "Kit not found"
          end
        else
          params[:page] = params[:page].nil? ? 1 : params[:page]
          @kits= Kitting::Kit.where(:status => 2,:edit_status => "FK",:cust_no => current_user,:parent_kit_id => nil,:category => nil)
        end
      else
        redirect_to  main_app.unauthorized_url
      end
    end

##
# This action is for initializing a new Kit creation process.
##
    def new
      if can?(:>=, "3")
        @binCenters_response = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
        if @binCenters_response
          @binCenters = @binCenters_response["errMsg"] == "" ? @binCenters_response['binCenterList'] : Array.new
          @media_type = Kitting::KitMediaType.where("customer_number in (?)",session[:customer_number])
          @kit = Kitting::Kit.new
          @kit_id = Kitting::Kit.last.present? ?  Kitting::Kit.last.id.to_i + 1 : 10000
          respond_to do |format|
            format.html   # new.html.erb
            format.json { render json: @kit }
          end
        else
          flash[:error] =  'Service temporary unavailable'
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is for creating a new Kit from the GUI.
##
    def create
      @kit = current_customer.kits.new(params[:kit])
      @kit.cust_no = current_user
      @kit.customer_id= current_customer.id
      @kit.created_by = current_customer.id
      @kit.updated_by = current_customer.id
      @kit.edit_status = "NK"
      @kit.status= "2"
      @kit.current_version = 0
      @kit.commit_status = false
      respond_to do |format|
        if @kit.save
          unless @kit.kit_media_type.kit_type == "binder" || @kit.kit_media_type.kit_type == "configurable" || @kit.kit_media_type.kit_type == "multi-media-type"
            @kit.create_cups(@kit, @kit.kit_media_type.compartment)
          end
          if @kit.kit_media_type.kit_type == "configurable"
            cup_layout = ''
            if @kit.kit_media_type.name == "Small Removable Cup TB"
              cup_layout = [[[1, 1, 1, 1], [2, 1, 1, 1], [3, 1, 1, 1], [1, 2, 1, 1], [2, 2, 1, 1], [3, 2, 1, 1],
                             [1, 3, 1, 1], [2, 3, 1, 1], [3, 3, 1, 1], [1, 4, 1, 1], [2, 4, 1, 1], [3, 4, 1, 1],
                             [1, 5, 1, 1], [2, 5, 1, 1], [3, 5, 1, 1], [1, 6, 1, 1], [2, 6, 1, 1], [3, 6, 1, 1]]]
            elsif @kit.kit_media_type.name == "Large Removable Cup TB"

              cup_layout =[[[1, 1, 1, 1], [2, 1, 1, 1], [3, 1, 1, 1], [4, 1, 1, 1], [5, 1, 1, 1], [6, 1, 1, 1], [7, 1, 1, 1], [8, 1, 1, 1], [9, 1, 1, 1], [10, 1, 1, 1],
                            [1, 2, 1, 1], [2, 2, 1, 1], [3, 2, 1, 1], [4, 2, 1, 1], [5, 2, 1, 1], [6, 2, 1, 1], [7, 2, 1, 1], [8, 2, 1, 1], [9, 2, 1, 1], [10, 2, 1, 1],
                            [1, 3, 1, 1], [2, 3, 1, 1], [3, 3, 1, 1], [4, 3, 1, 1], [5, 3, 1, 1], [6, 3, 1, 1], [7, 3, 1, 1], [8, 3, 1, 1], [9, 3, 1, 1], [10, 3, 1, 1],
                            [1, 4, 1, 1], [2, 4, 1, 1], [3, 4, 1, 1], [4, 4, 1, 1], [5, 4, 1, 1], [6, 4, 1, 1], [7, 4, 1, 1], [8, 4, 1, 1], [9, 4, 1, 1], [10, 4, 1, 1]],
                           [[1, 1, 1, 1], [2, 1, 1, 1], [1, 2, 1, 1], [2, 2, 1, 1]],
                           [[1, 1, 1, 1], [2, 1, 1, 1], [1, 2, 1, 1], [2, 2, 1, 1]]]
            elsif @kit.kit_media_type.name == "Small Configurable TB"
              cup_layout = [[[1,1,2,1],[3,1,2,1],[5,1,2,1]],
                            [[1,1,2,1],[3,1,2,1],[5,1,2,1]],
                            [[1,1,1,1],[2,1,2,1],[4,1,2,1],[6,1,1,1]]]
            end
            cup_count = cup_layout.count
            @kit.create_config_cups(@kit, cup_count,cup_layout)
          end

          if @kit.kit_media_type.kit_type == "binder"
            flash[:notice] = "Created sleeves #{undo_link}"
          else
            flash[:notice] = "Created #{@kit.cups.size} cups #{undo_link}"
          end

          format.html { redirect_to(action: 'detail_design',
                                    kit_number: @kit.kit_number,
                                    kit_media_type: @kit.kit_media_type.name, compartments: @kit.kit_media_type.compartment,
                                    compartment_layout: @kit.kit_media_type.compartment_layout, kit_id: @kit.id, bincenter: @kit.bincenter, :commit_status => @kit.commit_status) }
        else
          format.html { redirect_to action: "new" }
          format.json { render json: @kit.errors, status: :unprocessable_entity }
        end
      end
    end

##
# This action is for Editing a Kit, after Editing its send for Approval.
##
    def edit
      if can?(:>=, "3")
        @kit = Kitting::Kit.find(params[:id])
        @media_type = Kitting::KitMediaType.where(:customer_number => current_user )
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is for Updating a Kit called after Editing a Kit.
##
    def update
      if can?(:>=, "3")
        @kit = Kitting::Kit.find(params[:id])
        @media_type = Kitting::KitMediaType.where(:customer_number => current_user )
        respond_to do |format|
          if @kit.update_attributes(params[:kit])
            format.html  { redirect_to(@kit,
                                       :notice => 'Kit is updated successfully.') }
            format.json  { head :no_content }
          else
            format.html  { render :action => "edit" }
            format.json  { render :json => @kit.errors,
                                  :status => :unprocessable_entity }
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is for Showing a Kit and its kit parts according to the layout.
# If a kit is listed in the Kit search page but is not saved in the DB,
#
##
    def show
      #---------------------------------------------------------------------------------------------
      #     Add Kit From CARDEX
      #---------------------------------------------------------------------------------------------
      @media_type = Kitting::KitMediaType.where(:customer_number => current_user )
      if Kitting::Kit.find_by_id(params[:id]).blank?
        @kit_response =  invoke_webservice method: "get", action: "kitting", query_string: {action: "I",custNo: current_user,kitNo: params[:id] }
        if @kit_response.present?
          media_type = Kitting::KitMediaType.find_by_name("--")
          part_size =  @kit_response["partNo"].size
          commit_status = @kit_response["kitStatus"].to_i == 1 ? 1 : 0
          ver = commit_status == 1 ? 1 : 0
          edit_status = "FK"
          description = @kit_response["kitDesc"].present? ? @kit_response["kitDesc"] : ""
          notes = @kit_response["kitNotes"].present? ? @kit_response["kitNotes"].join("<br/>").split("<br/>").map { |note| note.strip}.uniq.join("<br/>") : ""
          @rbo_kit = { :notes=> notes, :description => description,:bincenter => @kit_response["kitLoc"], :kit_number => @kit_response["kitNo"],:status => @kit_response["kitStatus"].to_i, :kit_media_type_id => media_type.id, cust_no: current_user, customer_id: current_customer.id, commit_status:commit_status,edit_status: edit_status,current_version: ver, created_by: current_customer.id, updated_by: current_customer.id }
          @kit_rbo = current_customer.kits.new(@rbo_kit)
          if @kit_response["kitDate"] != "" && @kit_response["kitTime"] != "" && !@kit_response["kitDate"].nil? && !@kit_response["kitTime"].nil?
            merge_time =  @kit_response["kitDate"].concat(" #{@kit_response["kitTime"]}")
            time = Time.zone.parse(merge_time).utc.in_time_zone('Eastern Time (US & Canada)')
            @kit_rbo.created_at = time
            @kit_rbo.updated_at = time
          end
          if @kit_rbo.save
            @kit_rbo.create_binder_cups(@kit_rbo, part_size,commit_status)
            if @kit_rbo.commit_status
              @kit_rbo.create_default_copy(@kit_rbo, current_customer)
            end
            @kit_response["partNo"].each_with_index do |part_no,i|
              @part = Part.find_by_part_number(@kit_response["partNo"][i])
              if @part.present?
                @part = @part
              else
                @part =Part.new(:part_number =>@kit_response["partNo"][i],:name => @kit_response["partDesc"][i])
                if @part.save
                  @part=@part
                end
              end
              cup_part = @part.cup_parts.where(:demand_quantity => @kit_response["qty"][i],:cup_id => @kit_rbo.cups[i].id, :commit_status => commit_status.to_s, :uom => @kit_response["um"][i]).first_or_initialize
              if cup_part.id.nil?
                cup_part.save(:validate => false)
              end
            end
          end
          params[:id] = @kit_rbo.id
        else
          redirect_to kits_path(:notice => "Service Temporarily unavailable")
        end
      end


      ########################  DISPLAY KITS #########################
      if @kit_rbo.try(:errors).blank?

        @parent_kit = Kitting::Kit.find(params[:id])

        if @parent_kit.kit_media_type.name == "Multiple Media Type"
          @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(params[:id],true).sort
          @multi_kit_for_edit = @multi_media_kits.first.id rescue ""
          if params[:mmt_kit_id] && !params[:mmt_kit_id].empty?
            @mmt_kit_id = Kitting::Kit.find(params[:mmt_kit_id])
            if @mmt_kit_id.deleted
              @mmt_kit_id = @multi_media_kits.first
            else
              @mmt_kit_id = @mmt_kit_id
            end
          end
          @kit = @mmt_kit_id || @multi_media_kits.first
        else
          @kit = @parent_kit
        end


        @dup_kit = Kitting::Kit.find_by_commit_id(params[:id])

        if @parent_kit.status == 1 and @parent_kit.commit_status == true and  @dup_kit.nil?

          respond_to do |format|
            format.html  # show.html.erb
            format.json  { render :json => @kit }
          end
        else
          @kit = @parent_kit
          if can?(:>=,"4")
            if @kit.status == 6
              if @kit.kit_status_details.present?
                flash[:notice] = "Kit has been Deactivated by #{@kit.kit_status_details.last.updated_by rescue ""} on #{@kit.kit_status_details.last.updated_at.strftime('%m-%d-%Y') rescue ""}. No Further processing allowed"
              else
                flash[:notice] = "This Kit is inactive, Please activate the kit for further actions."
              end
              redirect_to :back
            else
              flash[:notice] = "Kit is yet to be approved, please approve the kit for further actions."
              respond_to do |format|
                format.html { redirect_to(action: 'detail_design',kit_number: @kit.kit_number,kit_media_type: @kit.kit_media_type.name, compartments: @kit.kit_media_type.compartment,compartment_layout: @kit.kit_media_type.compartment_layout, kit_id: @kit.id, bincenter: @kit.bincenter, :commit_status => @kit.commit_status) }
              end
            end
          else
            flash[:alert] = "This Kit is Pending, Once it is approved you can view the details."
            redirect_to :back
          end
        end
      else
        flash[:error] = "#{@kit_rbo.errors.full_messages.join(",")} <br/> #{@kit_response["errMsg"]}".html_safe rescue @kit_response["errMsg"]
        respond_to do |format|
          format.html  { redirect_to(kits_path,:error => "#{@kit_rbo.errors.messages.first.flatten.join(" ")}, Can't Import Kit from Cardex") }
          format.json  { head :no_content }
        end
      end
    end

##
#This action is called when reset kit link is called, it deletes the kit and all its associations.
##
    def destroy
      if can?(:>=, "3")
        @kit = Kit.find_by_id_and_commit_status(params[:id],false)
        if @kit.present?
          if @kit.kit_media_type.kit_type == "multi-media-type"
            @mmt_dup_kits = Kitting::Kit.where(:parent_kit_id => @kit.id)
            @mmt_dup_kits.map { |kit| kit.cup_parts.where(:commit_status => false).destroy_all }
            @mmt_dup_kits.map { |kit| kit.cups.where(:commit_status => false).destroy_all }
            @kit.destroy
          else
            @kit.cup_parts.where(:commit_status => false).destroy_all
            @kit.cups.where(:commit_status => false).destroy_all
            @kit.destroy
          end
        else
          @kits = Kit.find_by_commit_id_and_commit_status(params[:id],false)
          @kit=Kit.find_by_id(@kits.commit_id)
          if @kit.kit_media_type.kit_type == "multi-media-type"
            @mmt_dup_kits = Kitting::Kit.where(:parent_kit_id => @kit.id)
            @mmt_dup_kits.map { |kit| kit.cup_parts.where(:commit_status => false).destroy_all }
            @mmt_dup_kits.map { |kit| kit.cups.where(:commit_status => false).destroy_all }
            @kits.destroy
          else
            @kits = Kit.find_by_commit_id_and_commit_status(params[:id],false)
            @kit=Kit.find_by_id(@kits.commit_id)
            @kit.cup_parts.where(:commit_status => false).destroy_all
            @kit.cups.where(:commit_status => false).destroy_all
            @kits.destroy
          end
        end
        respond_to do |format|
          format.html { redirect_to :back,:notice => "Kit Was Reset Successfully" }
          format.json { head :no_content }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
#This action shows the actual design of a kit, in this action the parts are added to cups of a kit.
##
    def detail_design
      if can?(:>=, "3")
        @binCenters_response = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
        @binCenters = @binCenters_response.nil? ? [] : @binCenters_response['binCenterList']
        @media_type = Kitting::KitMediaType.where("customer_number in (?) and name != (?)",session[:customer_number], 'Multiple Media Type')
        if Kit.find_by_id(params[:kit_id]).present?
          @parent_kit = Kitting::Kit.find(params[:kit_id])
          if @parent_kit.kit_media_type.name == "Multiple Media Type"
            @multi_media_kits = Kitting::Kit.where(:parent_kit_id => Kitting::Kit.find(params[:kit_id]), :deleted => false).sort
            if @multi_media_kits.size > 0
              if params[:mmt_kit_id] && !params[:mmt_kit_id].empty?
                @mmt_kit_id = Kitting::Kit.find(params[:mmt_kit_id])
                if @mmt_kit_id.deleted
                  @mmt_kit_id = @multi_media_kits.first
                else 
                  @mmt_kit_id = @mmt_kit_id
                end
              end
              @original_kit = @mmt_kit_id || @multi_media_kits.first
              params[:compartment_layout] = @original_kit.kit_media_type.compartment_layout
              if Kitting::Kit.where(:id => @original_kit.id).first.kit_media_type.kit_type == "configurable"
                @cups = Kitting::Cup.find_all_by_kit_id_and_commit_id_and_status(@original_kit.id,nil,1)
              else
                @cups = Kitting::Cup.find_all_by_kit_id_and_commit_id(@original_kit.id,nil)
              end
            else
              @multi_media_kits = []
              @original_kit = Kitting::Kit.find(params[:kit_id])
            end
          else
            @original_kit = @parent_kit
            if Kitting::Kit.where(:id => params[:kit_id]).first.kit_media_type.kit_type == "configurable"
              @cups = Kitting::Cup.find_all_by_kit_id_and_commit_id_and_status(params[:kit_id],nil,1)
            else
              @cups = Kitting::Cup.find_all_by_kit_id_and_commit_id(params[:kit_id],nil)
            end
          end
          @duplicate_kit = Kit.where(:commit_id =>@original_kit.id, :kit_number => @original_kit.kit_number)
          if @duplicate_kit.blank?
            @kit = @original_kit
          else
            @kit = @duplicate_kit.first
          end
          respond_to do |format|
            format.html {}
            format.js {}
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is called by AJAX function while adding a part in the detail design page. It calls the get_part_numbers
# method and returns all the part numbers based on the response from that action as a json object
##
    def part_look_up
      params[:part_number]= Iconv.conv("UTF-8//IGNORE", "UTF-8",params[:part_number])
      @temp = get_part_numbers(current_user, params[:part_number].upcase)
      render json: @temp
    end

##
# This action is called by AJAX function while adding a part in the detail design page. It calls an RBO action
# to validate whether the part has valid UM or not.
##
    def uom_look_up
      @check_uom = invoke_webservice method: 'get', class: 'custInv/',action:'vldPartNoUM', query_string: {custNo: current_user, partNo: params[:part].strip , UM: params[:uom] }
      render json: @check_uom
    end

##
#  TODO ADD DESCRIPTION OF UPDATE CARDEX ACTION
#
##
    def update_cardex
      if can?(:>=, "3")
        @orig_kit= Kitting::Kit.find_by_kit_number_and_commit_id(params[:kit_number],nil)

        if @orig_kit.kit_media_type.kit_type == "multi-media-type"

          misc_arr= Array.new;parts_arr=Array.new;quantity_arr=Array.new ;uom_arr=Array.new;
          @dup_kit= Kitting::Kit.where(:commit_id => @orig_kit.id)
          @kit = @dup_kit.present? ? @dup_kit.first : @orig_kit

          @orig_mmt_kits = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(@orig_kit.id, false).sort
          @orig_mmt_kits.each_with_index do |orig_kit, index|

            @dup_mmt_kit= Kitting::Kit.where(:commit_id => orig_kit.id)
            @mmt_kit = @dup_mmt_kit.present? ? @dup_mmt_kit.first : orig_kit

            mmt_kit_details = Kitting::Kit.get_kit_data(orig_kit)
            misc_arr.push(*mmt_kit_details[:misc])
            parts_arr.push(*mmt_kit_details[:parts])
            quantity_arr.push(*mmt_kit_details[:quantity])
            uom_arr.push(*mmt_kit_details[:uom])
          end
          @kit_details = { :misc =>misc_arr,:parts=>parts_arr,:quantity => quantity_arr, :uom=> uom_arr }
        else
          @dup_kit= Kitting::Kit.where(:commit_id => @orig_kit.id)
          @kit = @dup_kit.present? ? @dup_kit.first : @orig_kit
          @kit_details=Kitting::Kit.get_kit_data(@orig_kit)
        end
        @kit.update_attribute("part_bincenter",params[:part_bin_center]) if params[:part_bin_center].present?
        @kit.update_attribute("bincenter",params[:kit_bin_center]) if params[:kit_bin_center].present?
        email_body = render_to_string "_approval_update_info", layout: false
        @line_station_update_email = invoke_webservice method: 'post', class: 'custInv/', action: 'lineStationUpdateEmail',
                                                       data: {
                                                           action:"7",
                                                           custNo:current_user,
                                                           emailBody: email_body,
                                                           subject:"Kit Action Request"
                                                       }
        if @line_station_update_email && @line_station_update_email["errMsg"].blank?
          if @dup_kit.present?
            @dup_kit.first.update_attribute("edit_status","FK")
          end
          if @orig_kit.kit_media_type.kit_type == "multi-media-type"
            @orig_mmt_kits.each_with_index do |orig_kit, index|
              orig_kit.update_attribute("edit_status","FK")
            end
          end
          @orig_kit.update_attribute("edit_status","FK")
          flash[:success] = "Kit Updated successfully and  is sent for approval."
          redirect_to kits_path
        else
          flash.now[:alert] = @line_station_update_email["errMsg"]
          redirect_to :back
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is for  updating the compartment layout in
# configurable kits while the user drag and drop the kit compartment
##
    def update_kit_layout
      @kit = Kitting::Kit.find_by_kit_number_and_commit_id(params[:kit_number],nil)
      if @kit.kit_media_type.kit_type == "configurable"
        if @kit.kit_media_type.name == "Small Removable Cup TB" && !params[:refresh_data]
          cup_layout = JSON.parse(params[:serialize_data]).select { |data| data if data["row"] < 7 }.map(&:values)
          small_removable_cup = Array.new
          cup_layout = small_removable_cup << cup_layout
        elsif @kit.kit_media_type.name == "Large Removable Cup TB" && !params[:refresh_data]
          large_removable_cup = Array.new
          large_removable_cup << JSON.parse(params[:serialize_data]).select { |data| data if data["row"] < 5 }.map(&:values)
          large_removable_cup << JSON.parse(params[:serialize_data_2]).select { |data| data if data["row"] < 3 }.map(&:values)
          large_removable_cup << JSON.parse(params[:serialize_data_3]).select { |data| data if data["row"] < 3 }.map(&:values)
          cup_layout = large_removable_cup
        elsif @kit.kit_media_type.name == "Small Configurable TB" && !params[:refresh_data]
          large_removable_cup = Array.new
          large_removable_cup << JSON.parse(params[:serialize_data]).select { |data| data if data["row"] < 2 }.map(&:values)
          large_removable_cup << JSON.parse(params[:serialize_data_2]).select { |data| data if data["row"] < 2 }.map(&:values)
          large_removable_cup << JSON.parse(params[:serialize_data_3]).select { |data| data if data["row"] < 2 }.map(&:values)
          cup_layout = large_removable_cup
        end
        @kit.update_config_cups(@kit, cup_layout,current_customer) unless params[:refresh_data]
        @kit.cups.where(:cup_dimension => nil).destroy_all
        @cups = Kitting::Cup.find_all_by_kit_id_and_commit_id_and_status(@kit.id,nil,1)
      end
    end

##
# This action is for adding a new cup in configurable kit, it returns the cup id if the cup is successfully added
#  else returns 0
##
    def add_widget_kit_layout
      @mmt_kit = Kitting::Kit.find_by_kit_number_and_commit_id(params[:kit_number],nil)

      @kit  = @mmt_kit.parent_kit_id ? Kitting::Kit.find_by_id(@mmt_kit.parent_kit_id) : @mmt_kit
      if @mmt_kit.kit_media_type.kit_type == "configurable"
        ActiveRecord::Base.transaction do
          cup = @mmt_kit.cups.create(:status => 1,:commit_status => false)
          @orig_kit = Kitting::Kit.find_by_kit_number_and_commit_id_and_commit_status(@kit.kit_number, nil,true)
          @dup_kit = Kitting::Kit.find_by_commit_id_and_commit_status(@kit.id,false)
          if @orig_kit.present?
            if @dup_kit.present?
              @dup_kit.update_attribute("updated_by",current_customer.id)
            else
              @new_kit = @kit.dup
              @new_kit.commit_status = false
              @new_kit.commit_id = @kit.id
              @new_kit.status = 2
              @new_kit.updated_by = current_customer.id
              @new_kit.save(:validate => false)
            end
          else
            @nk_kit = Kitting::Kit.find_by_commit_id_and_status(nil,false)
            if @nk_kit.present?
              @nk_kit.update_attribute("updated_by",current_customer.id)
            end
          end
          if cup.present?
            render json: {"cup_id"=> cup.id}
          else
            render json: {"cup_id"=> 0 }
          end
        end
      end
    end

##
# This action is for approving kits, it calls an RBO method for approving kits.
# This action is also responsible for the transaction state for a kit.
##
    def approve_kits
      if can?(:>, "4")
        kit_number=params[:kit_number]
        @orig_kit= Kitting::Kit.where(:kit_number => kit_number, :commit_id => nil).first
        @kit = Kitting::Kit.where(:kit_number => kit_number,:commit_status =>false).first
        @kit.update_attribute("description", @orig_kit.description) if (@orig_kit.present? && @orig_kit.description.present?)
        @dup_kit=Kitting::Kit.find_by_commit_id(@orig_kit.id)

        ########## START CODE LOGIC FOR SAVING PART BINCENTER TO KITS #######################
        if params[:part_bincenter].present?
          @kit_to_update = @dup_kit.present? ? @dup_kit : @orig_kit
          @kit_to_update.update_attribute("part_bincenter", params[:part_bincenter])
        end
        ########## END CODE LOGIC FOR SAVING PART BINCENTER TO KITS #########################


        @kit_copy = Kitting::KitCopy.where(:kit_id => @orig_kit.id)

        if @kit.present?
          if @orig_kit.kit_media_type.kit_type == "multi-media-type"
            misc_arr= Array.new;parts_arr=Array.new;quantity_arr=Array.new ;uom_arr=Array.new;in_contract_arr=Array.new;
            @orig_mmt_kits = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(@orig_kit.id, false).sort
            @orig_mmt_kits.each_with_index do |orig_kit, index|
              mmt_kit_details = Kitting::Kit.get_kit_data(orig_kit,"multi-media-type",index)
              misc_arr.push(*mmt_kit_details[:misc])
              parts_arr.push(*mmt_kit_details[:parts])
              quantity_arr.push(*mmt_kit_details[:quantity])
              uom_arr.push(*mmt_kit_details[:uom])
              in_contract_arr.push(*mmt_kit_details[:in_contract_status])
            end
            @kit_records = { :misc =>misc_arr,:parts=>parts_arr,:quantity => quantity_arr, :uom=> uom_arr, :in_contract_status =>in_contract_arr }
          else
            @kit_records = Kitting::Kit.get_kit_data(@orig_kit)
          end

          if @kit_records[:parts].present?
            contract_parts = []
            contract_misc = []
            contract_quantity = []
            contract_uom = []
            @kit_records[:in_contract_status].each_with_index do |contract_status,index|
              if contract_status
                contract_parts << @kit_records[:parts][index]
                contract_misc << @kit_records[:misc][index]
                contract_quantity << @kit_records[:quantity][index]
                contract_uom << @kit_records[:uom][index]
              end
            end
          end
          @check_kit =  invoke_webservice method: "get", action: "kitting", query_string: { action: "SK",custNo: current_user,kitStatuses: "1,2",kitNo: kit_number.upcase }
          if @check_kit["errMsg"].blank?
            if @check_kit["kitNoList"].present?
              @check_kit["kitNoList"].include?(@kit.kit_number.upcase) ? action="M" : action = "N"
            else
              action="N"
            end
          else
            action = "N"
          end
          data= { action:action,custNo: current_user,user:session[:user_name],kitNo: @kit.kit_number.upcase,kitStatus: "1",
                  kitLoc: @kit.bincenter,
                  partNo: contract_parts,
                  um:     contract_uom,
                  misc1:  contract_misc,
                  qty:    contract_quantity,
                  kitVer:"001",
                  kitDesc:@kit.description.nil? ? "" :@kit.description,
                  kitNotes:[@kit.notes.nil? ? "" : @kit.notes ]
          }
          @response = invoke_webservice method: 'post',action: 'kitting',
                                        data: {
                                            action:    action,
                                            custNo:    current_user,
                                            user:      session[:user_name],
                                            kitNo:     @kit.kit_number.upcase,
                                            kitStatus: "1",
                                            kitLoc:    @kit.bincenter,
                                            partNo:    contract_parts,
                                            um:        contract_uom,
                                            misc1:     contract_misc,
                                            qty:       contract_quantity,
                                            kitVer:    "001",
                                            kitDesc:   @kit.description.nil? ? "" :@kit.description,
                                            kitNotes:  [@kit.notes.nil? ? "" : @kit.notes ]
                                        }
          if @response.nil?
            flash.now[:notice] = "Time out error, please check VPN connection or RBO connectivity"

            redirect_to :back
          end
          if @response["errCode"]=="0"

            ########## START CODE LOGIC FOR TRACKING KIT VERSION #######################
            begin
              track_kit = Kitting::Kit.find_by_id_and_commit_status(@orig_kit.id,true)
              if track_kit.present?
                if track_kit.kit_media_type.kit_type == "multi-media-type"
                  multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status_and_deleted(track_kit,true,false).sort
                  cups = Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => track_kit.id),:commit_status => true)
                  cup_ids = cups.map(&:id)
                  cup_parts = Kitting::CupPart.where(:cup_id => cup_ids)
                  cup_parts.each do |cup_part|
                    kit_id = Kitting::Cup.where(:id => cup_part.cup_id).first.kit.id
                    cup_part.box_number = multi_media_kits.index(multi_media_kits.select { |kit| kit.id == kit_id}.first) + 1
                  end
                else
                  cups = track_kit.cups.where(:commit_status => true)
                  cup_parts = track_kit.cup_parts.where(:commit_status => true)
                end
                version = track_kit.current_version
                kit_number = track_kit.kit_number
                kit_id = track_kit.id
                #cup_parts.to_json(:methods => %w(box_number))

                @track_version = Kitting::KitVersionTrack.new(:kit=> track_kit.to_json, :cups=> cups.to_json, :cup_parts => cup_parts.to_json(:methods => %w(box_number)), :kit_version => version, :kit_id => kit_id, :kit_number => kit_number)
                #@track_version = Kitting::KitVersionTrack.new(kit: Marshal.dump(track_kit), cups: Marshal.dump(cups.to_a), cup_parts: Marshal.dump(cup_parts.to_a), kit_version: version, kit_id: kit_id, kit_number: kit_number)
                @track_version.save
              end
            rescue
              config.logger.warn "{\"VERSION TRACK EXCEPTION\":\" #{@orig_kit.inspect}\"}" rescue " ERROR WHILE LOGGING VERSION TRACK EXCEPTION."
              Rails.logger.info "A Error Has Occured while Marshalling"
            end
            ########## END CODE LOGIC FOR TRACKING KIT VERSION #########################


            ##########################################################################
            ## CODE LOGIC FOR DELETING DUPLICATE ENTRIES START ##
            ######### KIT DUPLICATE RECORD DELETION START ################
            ActiveRecord::Base.transaction do
              # Start of Transaction Block
              if @orig_kit.kit_media_type.kit_type == "multi-media-type"
                @orig_mmt_kits = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(@orig_kit.id, false).sort
                @mmt_kits_to_delete = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(@orig_kit.id, true).sort

                @orig_mmt_kits.each_with_index do |orig_kit, index|
                  orig_kit.commit_status=true
                  orig_kit.save(:validate => false)
                end

                @mmt_kits_to_delete.each_with_index do |kit, index|
                  kit.destroy
                end

              end
              if @dup_kit.present?
                @orig_kit.notes=@dup_kit.notes
                @orig_kit.description=@dup_kit.description
                @orig_kit.status=1
                @orig_kit.bincenter = @dup_kit.bincenter if @dup_kit.bincenter.present?
                @orig_kit.part_bincenter = @dup_kit.part_bincenter if @dup_kit.part_bincenter.present?
                @orig_kit.current_version= @dup_kit.current_version.to_i + 1
                @orig_kit.commit_status=true
                @orig_kit.updated_by = @dup_kit.updated_by
                @orig_kit.save(:validate => false)
                @dup_kit.destroy
              else
                @orig_kit.commit_status=true
                @orig_kit.current_version =  @orig_kit.current_version.to_i + 1
                @orig_kit.status=1
                @orig_kit.updated_by = current_customer.id
                @orig_kit.save(:validate => false)
              end



              ######### KIT DUPLICATE RECORD DELETION END ################

              ############ CUP DUPLICATE RECORD DELETION START ###############
              if @orig_kit.kit_media_type.kit_type == "multi-media-type"
                @orig_mmt_kits = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(@orig_kit.id, false).sort
                @orig_mmt_kits.each_with_index do |orig_kit, index|
                  orig_kit.cups.where(:commit_id => nil).each do |cup|
                    @dup_cup= Kitting::Cup.find_by_commit_id(cup.id)
                    if @dup_cup.present?
                      cup.ref1=@dup_cup.ref1
                      cup.ref2=@dup_cup.ref2
                      cup.ref3=@dup_cup.ref3
                      cup.status=@dup_cup.status
                      cup.cup_dimension = @dup_cup.cup_dimension
                      cup.cup_number = @dup_cup.cup_number
                      cup.commit_status = true
                      cup.save(:validate => false)
                      @dup_cup.destroy

                      ################# CUP PART DUPLICATE RECORD DELETION START ####################
                      cup.cup_parts.where(:commit_id => nil).each do |cup_part|
                        @dup_cup_parts = CupPart.where(:commit_id => cup_part.id, :cup_id => cup.id)
                        @dup_cup_parts.each do |dup_cup_part|
                          cup_part.demand_quantity = dup_cup_part.demand_quantity
                          cup_part.status =dup_cup_part.status
                          cup_part.commit_status = true
                          cup_part.uom = dup_cup_part.uom if dup_cup_part.uom.present?
                          cup_part.save(:validate => false)
                          dup_cup_part.destroy
                        end
                        if cup_part.commit_status == false
                          cup_part.commit_status =true
                          cup_part.save(:validate => false)
                        end
                      end
                      ################# CUP PART DUPLICATE RECORD DELETION END ######################
                    else
                      cup.commit_status =true
                      cup.save(:validate => false)
                      cup.cup_parts.where(:commit_id => nil).each do |cup_part|
                        @dup_cup_parts = CupPart.where(:commit_id => cup_part.id, :cup_id => cup.id)
                        @dup_cup_parts.each do |dup_cup_part|
                          cup_part.demand_quantity = dup_cup_part.demand_quantity
                          cup_part.status =dup_cup_part.status
                          cup_part.commit_status = true
                          cup_part.uom = dup_cup_part.uom if dup_cup_part.uom.present?
                          cup_part.save(:validate => false)
                          dup_cup_part.destroy
                        end
                        if cup_part.commit_status == false
                          cup_part.commit_status =true
                          cup_part.save(:validate => false)
                        end
                      end
                    end
                  end
                end
              else
                @orig_kit.cups.where(:commit_id => nil).each do |cup|
                  @dup_cup= Kitting::Cup.find_by_commit_id(cup.id)
                  if @dup_cup.present?
                    cup.ref1=@dup_cup.ref1
                    cup.ref2=@dup_cup.ref2
                    cup.ref3=@dup_cup.ref3
                    cup.status=@dup_cup.status
                    cup.cup_dimension = @dup_cup.cup_dimension
                    cup.cup_number = @dup_cup.cup_number
                    cup.commit_status = true
                    cup.save(:validate => false)
                    @dup_cup.destroy

                    ################# CUP PART DUPLICATE RECORD DELETION START ####################
                    cup.cup_parts.where(:commit_id => nil).each do |cup_part|
                      @dup_cup_parts = CupPart.where(:commit_id => cup_part.id, :cup_id => cup.id)
                      @dup_cup_parts.each do |dup_cup_part|
                        cup_part.demand_quantity = dup_cup_part.demand_quantity
                        cup_part.status =dup_cup_part.status
                        cup_part.commit_status = true
                        cup_part.uom = dup_cup_part.uom if dup_cup_part.uom.present?
                        cup_part.save(:validate => false)
                        dup_cup_part.destroy
                      end
                      if cup_part.commit_status == false
                        cup_part.commit_status =true
                        cup_part.save(:validate => false)
                      end
                    end
                    ################# CUP PART DUPLICATE RECORD DELETION END ######################
                  else
                    cup.commit_status =true
                    cup.save(:validate => false)
                    cup.cup_parts.where(:commit_id => nil).each do |cup_part|
                      @dup_cup_parts = CupPart.where(:commit_id => cup_part.id, :cup_id => cup.id)
                      @dup_cup_parts.each do |dup_cup_part|
                        cup_part.demand_quantity = dup_cup_part.demand_quantity
                        cup_part.status =dup_cup_part.status
                        cup_part.commit_status = true
                        cup_part.uom = dup_cup_part.uom if dup_cup_part.uom.present?
                        cup_part.save(:validate => false)
                        dup_cup_part.destroy
                      end
                      if cup_part.commit_status == false
                        cup_part.commit_status =true
                        cup_part.save(:validate => false)
                      end
                    end
                  end
                end
              end
              # End Of Transaction Block !!!
            end
            ######################## START LOGIC FOR RESETTING CUP NUMBER IN CONFIGURABLE #########################
            if @orig_kit.kit_media_type.kit_type == "multi-media-type"
              @orig_mmt_kits = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(@orig_kit.id, false).sort
              @orig_mmt_kits.each_with_index do |orig_kit, index|
                if orig_kit.kit_media_type.kit_type == "configurable"
                  cups_with_true_status = orig_kit.cups.where(:status => true)
                  cup_layout = Array.new

                  if orig_kit.kit_media_type.name == "Small Removable Cup TB"
                    cups_with_true_status.each do |cup|
                      cup_layout << cup.cup_dimension.split(",").map(&:to_i) if cup.cup_dimension.present?
                    end
                    whole_cup_layout = Array.new
                    cup_layout = whole_cup_layout << cup_layout
                  elsif orig_kit.kit_media_type.name == "Large Removable Cup TB" || orig_kit.kit_media_type.name == "Small Configurable TB"
                    whole_group = Array.new
                    group_one = Array.new
                    group_two = Array.new
                    group_three = Array.new
                    cups_with_true_status.each do |cup|
                      group_id = cup.cup_dimension.split(',')[4].to_i
                      if group_id == 1
                        group_one << cup.cup_dimension.split(",").map(&:to_i) if cup.cup_dimension.present?
                      elsif group_id == 2
                        group_two << cup.cup_dimension.split(",").map(&:to_i) if cup.cup_dimension.present?
                      elsif group_id == 3
                        group_three << cup.cup_dimension.split(",").map(&:to_i) if cup.cup_dimension.present?
                      end
                    end
                    whole_group << group_one if group_one.size > 0
                    whole_group << group_two if group_two.size > 0
                    whole_group << group_three if group_three.size > 0
                    cup_layout = whole_group
                  end
                  orig_kit.update_config_cups orig_kit,  cup_layout,current_customer, true
                  begin
                    config.logger.warn "{\"CONFIGURABLE KIT RESET\":\" #{orig_kit.inspect}\"}"
                    config.logger.warn "{\"CONFIGURABLE CUP RESET\":\" #{orig_kit.cups.inspect}\"}"
                  rescue " ERROR WHILE LOGGING VERSION TRACK EXCEPTION FOR CONFIGURABLE."
                  end
                end
              end
            else
              if @orig_kit.kit_media_type.kit_type == "configurable"
                cups_with_true_status = @orig_kit.cups.where(:status => true)
                cup_layout = Array.new
                if @orig_kit.kit_media_type.name == "Small Removable Cup TB"
                  cups_with_true_status.each do |cup|
                    cup_layout << cup.cup_dimension.split(",").map(&:to_i) if cup.cup_dimension.present?
                  end
                  whole_cup_layout = Array.new
                  cup_layout = whole_cup_layout << cup_layout
                elsif @orig_kit.kit_media_type.name == "Large Removable Cup TB" || @orig_kit.kit_media_type.name == "Small Configurable TB"
                  whole_group = Array.new
                  group_one = Array.new
                  group_two = Array.new
                  group_three = Array.new
                  cups_with_true_status.each do |cup|
                    group_id = cup.cup_dimension.split(',')[4].to_i
                    if group_id == 1
                      group_one << cup.cup_dimension.split(",").map(&:to_i) if cup.cup_dimension.present?
                    elsif group_id == 2
                      group_two << cup.cup_dimension.split(",").map(&:to_i) if cup.cup_dimension.present?
                    elsif group_id == 3
                      group_three << cup.cup_dimension.split(",").map(&:to_i) if cup.cup_dimension.present?
                    end
                  end
                  whole_group << group_one if group_one.size > 0
                  whole_group << group_two if group_two.size > 0
                  whole_group << group_three if group_three.size > 0
                  cup_layout = whole_group
                end
                @orig_kit.update_config_cups @orig_kit,  cup_layout,current_customer, true
                begin
                  config.logger.warn "{\"CONFIGURABLE KIT RESET\":\" #{@orig_kit.inspect}\"}"
                  config.logger.warn "{\"CONFIGURABLE CUP RESET\":\" #{@orig_kit.cups.inspect}\"}"
                rescue " ERROR WHILE LOGGING VERSION TRACK EXCEPTION FOR CONFIGURABLE."
                end
              end
            end


            ######################## STOP LOGIC FOR RESETTING CUP NUMBER IN CONFIGURABLE ##########################

            ############ CUP DUPLICATE RECORD DELETION END #################

            ## CODE LOGIC FOR DELETING DUPLICATE ENTRIES END ##
            ##########################################################################
            ##################### CREATE DEFAULT KIT COPY START ######################
            @orig_kit.create_default_copy(@orig_kit, current_customer)   if @orig_kit.current_version == 1
            ################ CREATE DEFAULT COPY END ############################
            respond_to do |format|
              format.html  { redirect_to(kits_path(:kit_number => params[:kit_number],:approved => true,:version=>@orig_kit.current_version),:notice => "Approved Kit(s) #{params[:kit_number]}") }
              format.json  { head :no_content }
            end
          else
            invalid_partlist = @response["invalidPartList"].join(",") if @response["invalidPartList"].present?
            error_message = invalid_partlist.present? ? "#{@response["errMsg"]} Invalid Part List : #{invalid_partlist}" : @response["errMsg"]
            flash[:notice] = error_message
            redirect_to :back
          end
        else
          flash.now[:notice] = "Kit is already approved."
          redirect_to :back
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is for downloading a sample csv that can be used for uploading kits from the csv file.
##
    def download_sample
      if can?(:>, "4")
        if params[:type] == "RFID"
          send_file Rails.public_path+"/excel/Import/sample_file_rfid_upload.csv", :disposition => "attachment"
        elsif params[:type] == "XLS"
          send_file Rails.public_path+"/excel/Import/sample_file_adhoc_kit.xlsx", :disposition => "attachment"
        else
          send_file Rails.public_path+"/excel/Import/sample_file_kit_upload.csv", :disposition => "attachment"
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is for uploading kits via a csv file it stores the csv related data into KitBomBulkOperation table.
##
    def upload
      if can?(:>, "4")
        params[:page] = params[:page].nil? ? 1 : params[:page]
        if params[:type] == "RFID"
          @operation_type = "RFID UPLOAD"
        else
          @operation_type = "KIT UPLOAD"
        end
        @kit_upload = Kitting::KitBomBulkOperation.new
        @kit_uploads = Kitting::KitBomBulkOperation.where("operation_type = ? and customer_id IN (?)",@operation_type,current_company).paginate(:page => params[:page], :per_page => 100).order('created_at desc')
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is for deleting csv upload related data from the KitBomBulkOperation table.
##
    def delete_upload_record
      if can?(:>, "4")
        @kit_upload =  Kitting::KitBomBulkOperation.find_by_id(params[:id])
        if @kit_upload
          directory = APP_CONFIG["csv_export_path"]
          path = @kit_upload.file_path
          if @kit_upload.operation_type == "PART CUP COUNT"
            export_path="Response_#{@kit_upload.id}_cup_count_#{path.gsub(".csv","")}.csv"
            FileUtils.rm_rf(File.join(directory,path),:secure => true ) rescue "Cannot Destroy File Path"
            FileUtils.rm_rf(File.join(directory,export_path),:secure => true ) rescue "Cannot Destroy File Path"
            @kit_upload.destroy
            flash[:success] = "Record & Response Files Deleted Successfully."
            redirect_to upload_parts_path
          else
            # Logic to Remove File Once Record is Deleted.
            if File.exist?(File.join(directory,path))
              FileUtils.rm_rf(File.join(directory,path),:secure => true ) rescue "Cannot Destroy File Path"
            elsif File.exist?(File.join(directory,"Response_#{@kit_upload.file_path.gsub(".csv","")}.csv"))
              FileUtils.rm_rf(File.join(directory,"Response_#{@kit_upload.file_path.gsub(".csv","")}.csv"),:secure => true ) rescue "Cannot Destroy File Path"
            elsif File.exist?(File.join(directory,"RFID_#{@kit_upload.id}.csv"))
              FileUtils.rm_rf(File.join(directory,"RFID_#{@kit_upload.id}.csv"),:secure => true ) rescue "Cannot Destroy File Path"
            else
              Rails.logger.warn "Deleting Record without any valid CSV File. #{@kit_upload.inspect}" rescue "Deleting Record without any valid CSV File."
            end
            @kit_upload.destroy
            flash[:success] = "Record & Response Files Deleted Successfully."
            if !request.env["HTTP_REFERER"].blank? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
              redirect_to :back
            else
              if params[:type] == "RFID UPLOAD"
                redirect_to upload_kits_path(:type => "RFID")
              else
                redirect_to upload_kits_path
              end
            end
            # redirect_to upload_kits_path                               # Removed redirect_to :back for this error Error : No HTTP_REFERER was set in the request to this action, so redirect_to :back could not be called successfully. If this is a test, make sure to specify request.env["HTTP_REFERER"].
          end
        else
          flash[:error] = "Something Went Wrong Contact KLX Administrator."
          if !request.env["HTTP_REFERER"].blank? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
            redirect_to :back
          else
            if params[:type] == "RFID UPLOAD"
              redirect_to upload_kits_path(:type => "RFID")
            else
              redirect_to upload_kits_path
            end
          end
          # redirect_to upload_kits_path                              # Removed redirect_to :back for this error Error : No HTTP_REFERER was set in the request to this action, so redirect_to :back could not be called successfully. If this is a test, make sure to specify request.env["HTTP_REFERER"].
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is for retrieving all entries from the KitBom table for listing the upload status of the file.
##
    def upload_status
      if can?(:>, "4")
        if params[:type] == "ADHOC"
          @operation_type = "AD HOC KIT"
        else
          @operation_type = "KIT UPLOAD"
        end
        @kit_uploads = Kitting::KitBomBulkOperation.where("operation_type = ? and customer_id IN (?)",@operation_type,current_company).paginate(:page => params[:id], :per_page => 100).order('created_at desc')
      else
        redirect_to main_app.unauthorized_url
      end
    end

# TODO CSV_IMPORT Description
    def csv_import
      if can?(:>, "4")
        name = params[:kit_bom_bulk_operation][:file].original_filename
        file_status = Kitting::KitBomBulkOperation.find_by_file_path( name )
        repeat = 0
        until file_status.nil? do
          repeat = 1 if repeat == 0
          file_status =  Kitting::KitBomBulkOperation.find_by_file_path("#{name}(#{repeat})")
          repeat +=1
        end
        if params[:kit_bom_bulk_operation][:operation_type] == "AD HOC KIT"
          mime_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          redirect_path = new_kit_work_order_path
          mule_path = '/datamigration/fullupload/agusta/kits'
          @kit_upload = current_customer.kit_bom_bulk_operations.create(:operation_type => params[:kit_bom_bulk_operation][:operation_type],:file_path => name,:status => "UPLOADING")
          directory = "public/excel/Import"
          file_path = repeat == 0 ?  name : "#{name}(#{repeat-1})"
          @kit_upload.update_attributes(:file_path => file_path,:status => "UPLOADING")
          path = File.join(directory, "#{@kit_upload.id}-CSV-#{name}")
          query = {:id => @kit_upload.id,:custId => current_customer.id,:custNo => current_user }.to_query
        else
          mime_type = "text/csv"
          redirect_path = upload_kits_path
          mule_path = '/datamigration/fullupload/kits'
          @kit_upload = current_customer.kit_bom_bulk_operations.create(:operation_type => "KIT UPLOAD",:file_path => name,:status => "UPLOADING")
          directory = "public/excel/Import"
          file_path = repeat == 0 ?  name : "#{name}(#{repeat-1})"
          @kit_upload.update_attributes(:file_path => file_path,:status => "UPLOADING")
          path = File.join(directory, "#{@kit_upload.id}-XLS-#{name}")
          query = {:id => @kit_upload.id,:custId => current_customer.id }.to_query
        end
        @file_status = File.open(path, "wb") { |f| f.write(params[:kit_bom_bulk_operation][:file].read) }
        if @kit_upload.update_attributes(:file_path => file_path,:status => "UPLOADING")
          begin
            webservice_uri = URI.join(APP_CONFIG['webservice_uri_format'], mule_path)
            uri = URI.parse(webservice_uri.to_s)
            http = Net::HTTP.new(uri.host, uri.port)
            if APP_CONFIG['webservice_uri_format'].include? "https"
              http.use_ssl = true
              http.verify_mode =  OpenSSL::SSL::VERIFY_NONE
            end
            http.open_timeout = 25
            http.read_timeout = 500
            @rbo_response = File.open(path) do |csv|
              # query = {:id => @kit_upload.id,:custId => current_customer.id }.to_query #application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
              request = Net::HTTP::Post::Multipart.new "#{uri.path}?#{query}", "file" => UploadIO.new(csv,mime_type,name)
              request.basic_auth APP_CONFIG['username'], APP_CONFIG['password']
              response = Net::HTTP.start(uri.host, uri.port) do |http|
                http.request(request)
              end
              JSON.parse(response.body) if response.code =~ /^2\d\d$/
            end
          rescue => e
            config.logger.warn  " CSV IMPORT ERROR #{__FILE__} , #{__LINE__},#{e.inspect} -- #{e.backtrace}" rescue "CSV IMPORT ERROR"
            Rails.logger.info " CSV IMPORT #{e.inspect} -- #{e.backtrace}"
          end

          if @rbo_response && @rbo_response["errMsg"].nil?
            FileUtils.rm(path) rescue ""
            flash[:success] = @rbo_response["successMsg"]
            redirect_to redirect_path
          else
            flash[:error] =  @rb_response.nil? ? "Service Temporarily Unavailable" : @rbo_response["errMsg"]
            FileUtils.rm(path) rescue ""
            @kit_upload.destroy
            redirect_to redirect_path
          end
        else
          flash[:error] = "INVALID FILE FORMAT."
          FileUtils.rm(path) rescue ""
          @kit_upload.destroy
          redirect_to redirect_path
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    def rfid_csv_import
      if can?(:>, "4")
        name = params[:kit_bom_bulk_operation][:file].original_filename
        file_status = Kitting::KitBomBulkOperation.find_by_file_path( name )
        repeat = 0
        until file_status.nil? do
          repeat = 1 if repeat == 0
          file_status =  Kitting::KitBomBulkOperation.find_by_file_path("#{name}(#{repeat})")
          repeat +=1
        end
        @kit_upload = current_customer.kit_bom_bulk_operations.create(:operation_type => "RFID UPLOAD",:file_path => name,:status => "UPLOADING")
        directory = "public/excel/Import"
        file_path = repeat == 0 ?  name : "#{name}(#{repeat-1})"
        path = File.join(directory, "#{@kit_upload.id}-CSV-#{name}")
        csv_export_directory = APP_CONFIG["csv_export_path"]
#        csv_export_path = @kit_upload.file_path rescue "Response_#{@kit_upload.id}.csv"
        @file_status = File.open(path, "wb") { |f| f.write(params[:kit_bom_bulk_operation][:file].read) }
        if @kit_upload.update_attributes(:file_path => file_path,:status => "UPLOADING")
          begin
            webservice_uri = URI.join(APP_CONFIG['webservice_uri_format'], '/datamigration/update/rfid')
            uri = URI.parse(webservice_uri.to_s)
            http = Net::HTTP.new(uri.host, uri.port)
            if APP_CONFIG['webservice_uri_format'].include? "https"
              http.use_ssl = true
              http.verify_mode =  OpenSSL::SSL::VERIFY_NONE
            end
            http.open_timeout = 25
            http.read_timeout = 500
            @rbo_response = File.open(path) do |csv|
              query = {:custNo => session[:customer_number]}.to_query
              request = Net::HTTP::Post::Multipart.new "#{uri.path}?#{query}", "file" => UploadIO.new(csv,"text/csv",name)
              request.basic_auth APP_CONFIG['username'], APP_CONFIG['password']
              response = Net::HTTP.start(uri.host, uri.port) do |http|
                http.request(request)
              end
              File.open(File.join(csv_export_directory,"RFID_#{@kit_upload.id}.csv"),"wb") { |f| f.write(response.body)}
            end
          rescue => e
            config.logger.warn  " CSV IMPORT ERROR #{__FILE__} , #{__LINE__},#{e.inspect} -- #{e.backtrace}" rescue "CSV IMPORT ERROR"
            Rails.logger.info " CSV IMPORT #{e.inspect} -- #{e.backtrace}"
          end
          if @rbo_response.nil?
            flash[:error] =  "Service Temporarily Unavailable"
            FileUtils.rm(path) rescue ""
            @kit_upload.destroy
            redirect_to upload_kits_path(:type => "RFID")
          else
            flash[:success] = "RFID File is uploaded sucessfuly"
            @kit_upload.update_attributes(:status => "COMPLETED")
            redirect_to upload_kits_path(:type => "RFID")
          end
        else
          flash[:error] = "INVALID FILE FORMAT."
          FileUtils.rm(path) rescue ""
          @kit_upload.destroy
          redirect_to upload_kits_path(:type => "RFID")
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

# EXPORT RESPONSE FILE OF PROCESSED CSV FOR KITS AND PART UPLOADS
    def csv_export
      if can?(:>, "4")
        directory= APP_CONFIG["csv_export_path"]
        @record = KitBomBulkOperation.find_by_id(params[:id])
        if params[:part_processing] == "true"
          path=@record.file_path  rescue "Response_#{@record.id}.csv"
        elsif params[:bom_download] == "true"
          path=@record.file_path  rescue "Response_#{@record.id}.csv"
        elsif @record.operation_type == "RFID UPLOAD"
          path="RFID_#{@record.id}.csv"
        elsif @record.operation_type == "AD HOC KIT"
          headers['Content-Type'] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          #file_extension = File.extname(@record.file_path)
          #path="WORK_ORDER_#{@record.id}_#{@record.file_path.gsub(file_extension,"")}#{file_extension}"
          if @record.file_path.include?("xlsx")
            path="WORK_ORDER_#{@record.id}_#{@record.file_path.gsub(".xlsx","")}.xlsx"
          else
            path="WORK_ORDER_#{@record.id}_#{@record.file_path.gsub(".xls","")}.xls"
          end
        else
          path="Response_#{@record.file_path.gsub(".csv","")}.csv"
          #path= @record.file_path rescue "Response_#{@record.file_path.gsub(".csv","")}.csv"
        end
        if File.exist?(File.join(directory,path))
          if @record.operation_type == "BOM DOWNLOAD"
            session.delete("BOM_ID")
            @record.destroy rescue config.logger.warn "Destroyed Record for #{params.inspect}"
          end
          send_file File.join(directory,path), :disposition => "attachment"
        else
          begin
            webservice_uri = URI.join(APP_CONFIG['webservice_uri_format'], '/datamigration/task/response',{"id" => params[:id]}.map{ |key, value| "#{key}=#{CGI.escape(value)}" }.join("&").insert(0, "?"))
            uri = URI.parse(webservice_uri.to_s)
            http = Net::HTTP.new(uri.host, uri.port)
            if APP_CONFIG['webservice_uri_format'].include? "https"
              http.use_ssl = true
              http.verify_mode =  OpenSSL::SSL::VERIFY_NONE
            end
            http.open_timeout = 25
            http.read_timeout = 500
            @rb_response = http.start do |http|
              request = Net::HTTP::Get.new(uri.request_uri)
              request.basic_auth APP_CONFIG['username'], APP_CONFIG['password']
              response = http.request request
            end
          rescue => e
            if @record.operation_type == "BOM DOWNLOAD"
              config.logger.warn  " REMOVING BOM ID FROM SESSION #{__FILE__}, #{__LINE__} , DATA IS #{session.inspect}"
              session.delete("BOM_ID")
            end
            config.logger.warn  " CSV EXPORT ERROR #{__FILE__} , #{__LINE__},#{e.inspect} -- #{e.backtrace}" rescue "CSV EXPORT ERROR"
            Rails.logger.info "CSV EXPORT #{e.inspect} -- #{e.backtrace}"
          end
          if @rb_response.nil?
            flash[:error] = "Service Temporarily Unavailable"
            if @record.operation_type == "BOM DOWNLOAD"
              config.logger.warn  " REMOVING BOM ID FROM SESSION #{__FILE__}, #{__LINE__} , DATA IS #{session.inspect}"
              session.delete("BOM_ID")
            end
            redirect_to :back
          else
            @data = JSON.parse(@rb_response.body) rescue "Success"
            if @data == "Success"
              File.open(File.join(directory,path),"wb"){ |f| f.write (@rb_response.body)}
              if File.exist?(File.join(directory,path))
                @record.update_attribute("is_downloaded",true)
                if @record.operation_type == "BOM DOWNLOAD"
                  config.logger.warn  " REMOVING BOM ID FROM SESSION #{__FILE__}, #{__LINE__} , DATA IS #{session.inspect}"
                  session.delete("BOM_ID")
                end
                begin
                  webservice_uri = URI.join(APP_CONFIG['webservice_uri_format'], '/datamigration/task/complete',{"id" => params[:id]}.map{ |key, value| "#{key}=#{CGI.escape(value)}" }.join("&").insert(0, "?"))
                  uri = URI.parse(webservice_uri.to_s)
                  http = Net::HTTP.new(uri.host, uri.port)
                  if APP_CONFIG['webservice_uri_format'].include? "https"
                    http.use_ssl = true
                    http.verify_mode =  OpenSSL::SSL::VERIFY_NONE
                  end
                  http.open_timeout = 25
                  http.read_timeout = 500
                  @rb_response = http.start do |http|
                    request = Net::HTTP::Get.new(uri.request_uri)
                    request.basic_auth APP_CONFIG['username'], APP_CONFIG['password']
                    response = http.request request
                  end
                rescue => e
                  if @record.operation_type == "BOM DOWNLOAD"
                    config.logger.warn  " REMOVING BOM ID FROM SESSION #{__FILE__}, #{__LINE__} , DATA IS #{session.inspect}"
                    session.delete("BOM_ID")
                  end
                  config.logger.warn  " CSV EXPORT ERROR #{__FILE__} , #{__LINE__},#{e.inspect} -- #{e.backtrace}" rescue "CSV EXPORT ERROR"
                  Rails.logger.info "CSV EXPORT #{e.inspect} -- #{e.backtrace}"
                end
              end
              send_file File.join(directory,path), :disposition => "attachment"
            else
              if @record.operation_type == "BOM DOWNLOAD"
                config.logger.warn  " REMOVING BOM ID FROM SESSION #{__FILE__}, #{__LINE__} , DATA IS #{session.inspect}"
                @record.destroy rescue config.logger.warn "DESTROYED RECORD FOR #{params.inspect}, #{__FILE__} , #{__LINE__}"
                session.delete("BOM_ID")
              end
              flash[:error] = @data["errMsg"]
              redirect_to :back
            end
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
#  This action is for printing Internal Labels, External Labels and Kit Description Labels.
##
    def print_label
      if can?(:>=, "4")
        if params[:commit] == 'Print Internal Label' && params[:internal_label_type] == "label_4"
          @kit = Kitting::Kit.includes(cup_parts: :cup).where(['cup_parts.status = ?', 1]).find(params[:kit_id])
          @cups = @kit.cups
          respond_to do |format|
            format.html do
              render :pdf => "print_label.html.erb",
                     :page_height => '2in',
                     :page_width => '1.2in',
                     :margin => {:top => 0.5,:bottom => 0,:left => 0,:right => 0 }
              #:@kit => {:font_name => "Lucida Sans Unicode", :l1_font_size => 25,:text => 'center'}
            end
          end
        elsif params[:commit] == 'Print Internal Label'
          @kit = Kitting::Kit.includes(cup_parts: :cup).where(['cup_parts.status = ?', 1]).find(params[:kit_id])
          @cups = @kit.cups
          respond_to do |format|
            format.html do
              render :pdf => "print_label.html.erb",
                     :page_height => '1.2in',
                     :page_width => '2in',
                     :margin => {:top => 0.5,:bottom => 0,:left => 0,:right => 0 }
              #:@kit => {:font_name => "Lucida Sans Unicode", :l1_font_size => 25,:text => 'center'}
            end
          end
        elsif params[:commit] == 'Print All Internal Label'  && params[:all_internal_label_type] == "label_4"
          current_kit = Kitting::Kit.where(:id => params[:kit_id])
          if current_kit.present?
            parent_kit_id = current_kit.first.parent_kit_id
            if parent_kit_id.present?
              @child_kit_ids = Kitting::Kit.where(:parent_kit_id => parent_kit_id).order("id asc").map(&:id)
              @cups = Kitting::Cup.where(:kit_id => @child_kit_ids)
              respond_to do |format|
                format.html do
                  render :pdf => "print_label.html.erb",
                         :page_height => '2in',
                         :page_width => '1.2in',
                         :margin => {:top => 0.5,:bottom => 0,:left => 0,:right => 0 }
                end
              end
            end
          end
        elsif params[:commit] == 'Print All Internal Label'
          current_kit = Kitting::Kit.where(:id => params[:kit_id])
          if current_kit.present?
            parent_kit_id = current_kit.first.parent_kit_id
            if parent_kit_id.present?
              @child_kit_ids = Kitting::Kit.where(:parent_kit_id => parent_kit_id).order("id asc").map(&:id)
              @cups = Kitting::Cup.where(:kit_id => @child_kit_ids)
              respond_to do |format|
                format.html do
                  render :pdf => "print_label.html.erb",
                         :page_height => '1.2in',
                         :page_width => '2in',
                         :margin => {:top => 0.5,:bottom => 0,:left => 0,:right => 0 }
                end
              end
            end
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
#  This action is called by an AJAX function when the kit type is binder and a cup part delete button is clicked.
##
    def delete_record
      if Kitting::Kit.find_by_id(params[:kit_id]).kit_media_type.kit_type== "binder"
        @binder_cup = Kitting::Cup.find(:all, :conditions => ['kit_id =?', params[:kit_id].to_i])
        @delete_cup = Kitting::Cup.find_by_id(params[:cup_id])
        @binder_cup.each do |cup|
          if(cup.status.nil? || cup.status != false) #checking if cup is deleted(if deleted status = false)
            if(@delete_cup.cup_number <= cup.cup_number)
              if( @delete_cup.cup_number == cup.cup_number )
                cup.update_attribute("cup_number", 0)
              else
                cup.update_attribute("cup_number", cup.cup_number - 1)
              end
            end
          end
        end
      end
      params[:part_number] = params[:part_number].strip
      @part_details = Kitting::Part.find_by_part_number(params[:part_number])
      @cup_part_details = Kitting::CupPart.where(:cup_id => params[:cup_id], :part_id => @part_details.id) rescue nil
      if @part_details.blank? || @cup_part_details.blank?
        @error = "Cup / Part Number Not Found Contact KLX Administrator."
      else
        @cup_part_details_commit_status = Kitting::CupPart.where(:cup_id => params[:cup_id], :part_id => @part_details.id,:commit_status => false)
        if @cup_part_details_commit_status[0].present?
          check_update_cup_part = @cup_part_details_commit_status[0].update_attribute("status",0)
          #@cup_part_details.update_all(:status => false) rescue ""
          if Kitting::Kit.find_by_id(params[:kit_id]).kit_media_type.kit_type== "binder"
            @cup = Kitting::Cup.find_by_id(params[:cup_id])
            @cup_commit_status = @cup.commit_status if @cup.present?
            if @cup_commit_status == true
              if Kitting::Cup.find_by_commit_id(params[:cup_id]).blank?
                @dup_cup = @cup.dup
                @dup_cup.commit_id = @cup.id
                @dup_cup.commit_status = false
                @dup_cup.status = false
                @dup_cup.save(:validate => false)
              else
                @cup= Kitting::Cup.find_by_commit_id(params[:cup_id]).update_attributes(:status=>false,:commit_status => false)
              end
            else
              @cup.update_attribute("status",false)
            end
          end
        else
          @dup_cup_part = Kitting::CupPart.new(:cup_id => params[:cup_id], :part_id => @part_details.id,:status => 0,:commit_status => false,:commit_id => @cup_part_details.first.id, :demand_quantity => @cup_part_details.first.demand_quantity )
          @dup_cup_part.save(:validate => false)
        end
        @kit_commit_id = Kitting::Kit.find_by_commit_id(params[:kit_id])
        if @kit_commit_id.present?
          @kit_commit_id.update_attribute("status",2)
        else
          @check_kit_status = Kitting::Kit.where(:id => params[:kit_id],:commit_status => true)
          if @check_kit_status.present?
            @kit= Kitting::Kit.find(params[:kit_id])
            @duplicate_kit = @kit.dup
            @duplicate_kit.commit_status = false
            @duplicate_kit.commit_id = @kit.id
            @duplicate_kit.status = 2
            @duplicate_kit.updated_by = current_customer.id
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
      if request.xhr?
        respond_to do |format|
          @cup = Kitting::Cup.find_by_id(params[:cup_id])
          request.format = :js
          format.js {}
        end
      else
        render nothing: true
      end
    end

##
#  This action is for the detail part Adding page when the kit type is binder.
##
    def detail_design_binder
      if can?(:>=, "3")
        @kit = Kitting::Kit.find_all_by_kit_id(params[:kit_id])
        @cups = Kitting::Cup.find_all_by_kit_id(params[:kit_id])
        render json: @cups
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
#  TODO Paging Description
##
    def paging
      redirect_to main_app.unauthorized_url unless session[:user_level] > "3"
    end

##
#  This action is initializes the KitCopy Creation page from Kit Show Page.
##
    def new_copy
      if can?(:>=, "4")
        @kit = Kitting::Kit.find(params[:id])
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
#  This Action Creates required number of copies of a kit, passing number of copies as a parameter.
##
    def create_copy
      if can?(:>=, "4")
        @kit = Kitting::Kit.find(params[:kit_id])
        loc = Kitting::Location.where('name = ?', "NEW KIT QUEUE")
        if loc.blank?
          copies = params[:number_of_copies].to_i
          copies.each do |copy|
            @kit_copy = current_customer.kit_copies.create(:kit_id => @kit.id, :kit_version_number => @kit.kit_number + "-"+ get_copy_number(@kit.id), :status => @kit.status, location_id: loc.first.id, :version_status => @kit.current_version)
            ###################  START TO INSERT INTO TRACK COPY VERSION #############
            if @kit_copy.present?
              @track_version = Kitting::TrackCopyVersion.create(kit_copy_id: @kit_copy.id, version: @kit_copy.version_status, picked_version:  @kit_copy.version_status, filled_version:  @kit_copy.version_status)
            end
            ################## STOP TRACK COPY VERSION ##############################
          end
        else
          copies = params[:number_of_copies].to_i
          1.upto(params[:number_of_copies].to_i) do |index|
            @kit_copy = current_customer.kit_copies.create( kit_id: @kit.id, kit_version_number: @kit.kit_number + "-"+ get_copy_number(@kit.id), status: @kit.status, location_id: loc.first.id,:version_status => @kit.current_version )
            ###################  START TO INSERT INTO TRACK COPY VERSION #############
            if @kit_copy.present?
              @track_version = Kitting::TrackCopyVersion.create(kit_copy_id: @kit_copy.id, version: @kit_copy.version_status, picked_version:  @kit_copy.version_status, filled_version:  @kit_copy.version_status)
            end
            ################### STOP TRACK COPY VERSION ##############################
          end
        end
        redirect_to kit_copies_path
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
#  This Action is for updating the kit notes along with transcation management of that kit. After updating the kit
#  is send for approval.
##
    def update_kit_details
      if can?(:>=, "3")
        if request.xhr?
          #if params[:notes].present?
          @orig_kit= Kitting::Kit.find_by_id(params[:kit_id])
          if @orig_kit.present?
            @duplicate_kit = Kitting::Kit.where(:commit_id => @orig_kit.id,:commit_status => false)
            if @duplicate_kit.present?
              @duplicate_kit.first.description= params[:description]
              if params[:notes].present?
                if @duplicate_kit.first.notes.present?
                  @duplicate_kit.first.notes = "#{@duplicate_kit.first.notes} <br/> #{params[:notes].strip}" unless params[:notes].strip == @duplicate_kit.first.notes.split("<br/>").last.strip
                else
                  @duplicate_kit.first.notes = params[:notes].strip
                end
              end
              @duplicate_kit.first.bincenter = params[:bincenter]
              @duplicate_kit.first.updated_by= current_customer.id
              @duplicate_kit.first.part_bincenter= params[:part_bincenter]
              @duplicate_kit.first.save(:validate => false)
            else
              if @orig_kit.commit_status == true
                @duplicate_kit = @orig_kit.dup
                @duplicate_kit.commit_status = false
                @duplicate_kit.commit_id = @orig_kit.id
                if params[:notes].present?
                  if @duplicate_kit.notes.present?
                    @duplicate_kit.notes = "#{@duplicate_kit.notes} <br/> #{params[:notes].strip}" unless params[:notes].strip == @duplicate_kit.notes.split("<br/>").last.strip
                  else
                    @duplicate_kit.notes = params[:notes].strip
                  end
                end
                @duplicate_kit.description = params[:description]
                @duplicate_kit.bincenter = params[:bincenter]
                @duplicate_kit.part_bincenter= params[:part_bincenter]
                @duplicate_kit.save(:validate => false)
                @duplicate_kit.updated_by= current_customer.id
                @duplicate_kit.update_attribute("status", 2)
              else
                if params[:notes].present?
                  if @orig_kit.notes.present?
                    @orig_kit.update_attributes(:notes => @orig_kit.notes.present? ? "#{@orig_kit.notes.strip} <br/> #{params[:notes].strip}" : params[:notes].strip,:description => params[:description],:bincenter => params[:bincenter],:part_bincenter => params[:part_bincenter],:updated_by => current_customer.id)  unless params[:notes].strip == @orig_kit.notes.split("<br/>").last.strip
                  else
                    @orig_kit.update_attributes(:updated_by=> current_customer.id,:notes => @orig_kit.notes.present? ? "#{@orig_kit.notes} <br/> #{params[:notes].strip}" : params[:notes].strip,:description => params[:description],:bincenter => params[:bincenter],:part_bincenter => params[:part_bincenter])
                  end
                else
                  @orig_kit.update_attributes(:description => params[:description],:updated_by=> current_customer.id,:bincenter => params[:bincenter],:part_bincenter => params[:part_bincenter])
                end
              end
            end
            render :json => {"status" => "Success"}
          end
        else
          flash[:error] = "Request Cannot be Processed Contact KLX representative"
          if !request.env["HTTP_REFERER"].blank? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
            redirect_to :back
          else
            redirect_to kits_path
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    def select_media_type
      @media_type = Kitting::KitMediaType.where("customer_number in (?)",session[:customer_number])
      render json: {"kit_media_types" => @media_type}
    end

    def add_media_type
      @kit = Kitting::Kit.find(params[:kit_id])
      sub_kit_count = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(params[:kit_id], false).size
      @sub_kit = @kit.dup
      @sub_kit.kit_number = @kit.kit_number.gsub("KIT","KIT-PART-#{sub_kit_count + 1 }")
      @sub_kit.kit_media_type_id = params[:kit_media_type_id]
      @sub_kit.commit_status = false
      @sub_kit.parent_kit_id = @kit.id

      if @sub_kit.save
        @sub_kit.update_attribute("kit_number", "KIT-PART-#{@sub_kit.id.to_s}-#{current_user}-#{@kit.id.to_s}")
        if @sub_kit.kit_media_type.kit_type == "non-configurable"
          @sub_kit.create_cups(@sub_kit, @sub_kit.kit_media_type.compartment)
        end
        if @sub_kit.kit_media_type.kit_type == "configurable"
          cup_layout = ''

          if @sub_kit.kit_media_type.name == "Small Removable Cup TB"
            cup_layout = [[[1, 1, 1, 1], [2, 1, 1, 1], [3, 1, 1, 1], [1, 2, 1, 1], [2, 2, 1, 1], [3, 2, 1, 1],
                           [1, 3, 1, 1], [2, 3, 1, 1], [3, 3, 1, 1], [1, 4, 1, 1], [2, 4, 1, 1], [3, 4, 1, 1],
                           [1, 5, 1, 1], [2, 5, 1, 1], [3, 5, 1, 1], [1, 6, 1, 1], [2, 6, 1, 1], [3, 6, 1, 1]]]
          elsif @sub_kit.kit_media_type.name == "Large Removable Cup TB"

            cup_layout =[[[1, 1, 1, 1], [2, 1, 1, 1], [3, 1, 1, 1], [4, 1, 1, 1], [5, 1, 1, 1], [6, 1, 1, 1], [7, 1, 1, 1], [8, 1, 1, 1], [9, 1, 1, 1], [10, 1, 1, 1],
                          [1, 2, 1, 1], [2, 2, 1, 1], [3, 2, 1, 1], [4, 2, 1, 1], [5, 2, 1, 1], [6, 2, 1, 1], [7, 2, 1, 1], [8, 2, 1, 1], [9, 2, 1, 1], [10, 2, 1, 1],
                          [1, 3, 1, 1], [2, 3, 1, 1], [3, 3, 1, 1], [4, 3, 1, 1], [5, 3, 1, 1], [6, 3, 1, 1], [7, 3, 1, 1], [8, 3, 1, 1], [9, 3, 1, 1], [10, 3, 1, 1],
                          [1, 4, 1, 1], [2, 4, 1, 1], [3, 4, 1, 1], [4, 4, 1, 1], [5, 4, 1, 1], [6, 4, 1, 1], [7, 4, 1, 1], [8, 4, 1, 1], [9, 4, 1, 1], [10, 4, 1, 1]],
                         [[1, 1, 1, 1], [2, 1, 1, 1], [1, 2, 1, 1], [2, 2, 1, 1]],
                         [[1, 1, 1, 1], [2, 1, 1, 1], [1, 2, 1, 1], [2, 2, 1, 1]]]
          elsif @sub_kit.kit_media_type.name == "Small Configurable TB"
            cup_layout = [[[1,1,2,1],[3,1,2,1],[5,1,2,1]],
                          [[1,1,2,1],[3,1,2,1],[5,1,2,1]],
                          [[1,1,1,1],[2,1,2,1],[4,1,2,1],[6,1,1,1]]]
          end
          cup_count = cup_layout.count
          @sub_kit.create_config_cups(@sub_kit, cup_count,cup_layout)
        end
        render json: {"status" => true, "message" => 'Added successfully.'}
      else
        render json: {"status" => false, "message" => @sub_kit.errors}
      end

    end

    def remove_media_type

      @mmt_kit = Kitting::Kit.find_by_id(params[:sub_kit_id])

      @kit = @mmt_kit.parent_kit_id ? Kitting::Kit.find_by_id(@mmt_kit.parent_kit_id) : @mmt_kit
      @dup_kit = Kitting::Kit.find_by_commit_id_and_commit_status(@kit.id,false)
      if @dup_kit.present?
        @dup_kit.update_attribute("updated_by",current_customer.id)
      else
        @dup_kit = @kit.dup
        @dup_kit.commit_status = false
        @dup_kit.commit_id = @kit.id
        @dup_kit.status = 2
        @dup_kit.updated_by= current_customer.id
        @dup_kit.save(:validate => false)
      end

      if @mmt_kit.update_attribute('deleted',true)
        render json: {"status" => true, "message" => 'Deleted successfully.'}
      else
        render json: {"status" => false, "message" => @mmt_kit.errors}
      end
    end

    private
##
#  This private method gets kit id as the argument and returns the next kit copy number.
# If no copies of the kit exist then 1 is returned.
##
    def get_copy_number id
      @commit_id = Kitting::Kit.find_by_id(id).commit_id if Kitting::Kit.find_by_id(id).present?
      if @commit_id.nil?
        if Kitting::KitCopy.find_all_by_kit_id(id).blank?
          count = 1
        else
          count = Kitting::KitCopy.find_all_by_kit_id(id).sort.last.try(:kit_version_number).split('-').last.to_i + 1
        end
        count.to_s
      else
        if Kitting::KitCopy.find_all_by_kit_id(@commit_id).blank?
          count = 1
        else
          count = Kitting::KitCopy.find_all_by_kit_id(@commit_id).count + 1
        end
        count.to_s
      end
    end

##
#  This private method gets kit id as the argument and returns the current copy number.
#  It is used to display the number of copies on kits search page.
##
    def number_of_copy kit_id
      @commit_id = Kitting::Kit.find_by_id(kit_id).commit_id if Kitting::Kit.find_by_id(kit_id).present?
      if @commit_id.nil?
        if Kitting::KitCopy.find_all_by_kit_id(kit_id).blank?
          count = 1
        else
          count = Kitting::KitCopy.find_all_by_kit_id(kit_id).count + 1
        end
        count.to_s
      else
        if Kitting::KitCopy.find_all_by_kit_id(@commit_id).blank?
          count = 1
        else
          count = Kitting::KitCopy.find_all_by_kit_id(@commit_id).count + 1
        end
        count.to_s
      end
    end

##
#  This private method gets called when clicking on undo link after kit creation for the first time. It undoes
# kit creation and destroys all association.
##
    def undo_link
      view_context.link_to("undo", revert_version_path(@kit.versions.last), :method => :post)
    end

##
#  This private method is used for pagination of search results.
##
    def divide_records_in_pages total_records
      total_page =  total_records/100
      if total_records/100 < 1
        total_page = 1
      else
        if total_records % 100 == 0
          total_page = total_records/100
        else
          total_page = (total_records/100) + 1
        end
      end
    end

##
#  This private method is called when deleting a part for binder type kits. It deletes the cup and part entries from
#  the respective tables
##
    def delete_binder_kit_part
      if Kitting::Kit.find_by_id(params[:kit_id]).kit_media_type.kit_type== "binder"
        @binder_cup = Kitting::Cup.find(:all, :conditions => ['kit_id =?', params[:kit_id].to_i])
        @delete_cup = Kitting::Cup.find_by_id(params[:cup_id])
        unless @binder_cup.nil?
          @binder_cup.each do |cup|
            if(cup.status.nil? || cup.status != false) #checking if cup is deleted(if deleted status = false)
              if(@delete_cup.cup_number <= cup.cup_number)
                if( @delete_cup.cup_number == cup.cup_number )
                  cup.update_attribute("cup_number", 0)
                else
                  cup.update_attribute("cup_number", cup.cup_number - 1)
                end
              end
            end
          end
        end
      end
    end

    helper_method :get_copy_number, :divide_records_in_pages, :number_of_copy
  end
end