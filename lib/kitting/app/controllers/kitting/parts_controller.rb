require_dependency "kitting/application_controller"
require "csv"
module Kitting
  class PartsController < ApplicationController
    include PartsHelper
    before_filter :get_acess_right, :except => [:search,:image]
    before_filter :add_headers, :only=>[ :download_sample,:csv_export ]

    ##
    # This action is for initializing New Part Image Creation Process.
    ##
    def new
      if can?(:>=, "3")
        @cup_count = params[:edit_cup_count].present? ? params[:edit_cup_count] : false
        if params[:xid]
          if params[:xid].class== Array
            part_number = params[:xid].join(",")
          else
            part_number = params[:xid]
          end
          @part_numbers = get_part_numbers current_user, part_number
          @search_partnumber = @part_numbers['searchPartList']
        end
        @part=Part.new
        respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @part }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action stores Part Image after making web service call and gettting part details from its response.
    ##
    def create
      if can?(:>=, "3")
        @cup_count = params[:cup_count].to_boolean
        @part = Kitting::Part.new(params[:part])
        @part_response =  get_part_numbers current_user, params[:part][:part_number].upcase
        if @part_response
          if @part_response["errCode"] == "1"
            flash.now[:notice] = @part_response["errMsg"]
            render :new
          else
            @part.name = @part_response['partName']
            @part.prime_pn = @part_response["primePNList"].reject(&:blank?).first
            # @part.customer_name = session[:customer_Name]
            # @part.customer_number = session[:customer_number]
            respond_to do |format|
              if @part.save
                flash.now[:message] = "Part #{@part.part_number} created successfully."
                format.html { redirect_to part_path(@part.id)  }
              else
                format.js
                format.html { render action: "new" }
              end
            end

          end
        else
          flash.now[:notice] = "Service temporary unavailable"
          render :new
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action is of index page of a kit part number
    ##
    def index
      if can?(:>=, "3")
        if params[:part_number]
          if params[:page].nil?
            params[:page] = 1
          end
          @part_number = params[:part_number].try(:strip).upcase
          @part_nums = invoke_webservice method: 'get', class: 'custInv/', action: 'partNums', query_string: { custNo: session[:customer_number],partNo: @part_number}

          if (@part_nums && @part_nums["errCode"] == "")
            @len = @part_nums["searchPartList"].length
            @result = @part_nums["searchPartList"].paginate(params[:page],100)
          end

          if (@part_nums && @part_nums["errCode"] == "")
            @web_portal_kit = invoke_webservice method: 'get', action: 'kitting',	query_string: { action: "SK", custNo: current_user, kitStatuses: "1,2,6", kitNo: @part_number }
            if @part_nums["errMsg"] != ""
              flash.now[:notice] = @part_nums["errMsg"]
            end
          else
            flash.now[:notice] = "Service temporary unavailable"
          end
          render :index
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action shows part details, image
    ##
    def show
      if can?(:>=, "3")
        @part = Kitting::Part.find(params[:id])
        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @part }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    # Creates Image Name Url Dynamically and stream the image content to O/P
    def image
      begin
        #send_file File.join(APP_CONFIG['part_image_path'],@part.id.to_s,@part.image_name.url.split("/").last),:disposition => 'inline'
        if File.exists?(File.join(params[:image]))
          data = open(params[:image])
          send_data data.read, disposition: 'inline', stream: 'true', stream: 'true'
          #send_file File.join(params[:image]),:disposition => 'inline'
        else
          data = open("#{Rails.root}/public/image_not_available.jpg")
          send_data data.read, disposition: 'inline', stream: 'true', stream: 'true'
        end

      rescue
        "No Image Found"
      end
    end

    ##
    # Edit/Add a part image
    ##
    def edit
      if can?(:>=, "3")
        @cup_count = params[:edit_cup_count].present? ? params[:edit_cup_count] : false
        @part = Kitting::Part.find(params[:id])
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # Save Edited Part Image
    ##


    def update
      if can?(:>=, "3")
        @cup_count = params[:cup_count].to_boolean
        @part = Kitting::Part.find(params[:id])
        if @part.name.blank? || @part.prime_pn.blank?
          get_part_name_rbo = get_part_numbers current_user, params[:part][:part_number].try(:upcase)
          @get_part_name = get_part_name_rbo['partName'] || ""
          @part.update_attribute(:name, @get_part_name)
          @part.update_attribute(:prime_pn, get_part_name_rbo["primePNList"].reject(&:blank?).first)
        end

        respond_to do |format|
          if @part.update_attributes(params[:part])
            format.html  { redirect_to(@part,:notice => "Part #{@part.part_number} is updated successfully.") }
            format.json  { head :no_content }
          else
            format.html  { render :action => "edit" }
            format.json  { render :json => @part.errors,
                                  :status => :unprocessable_entity }
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # Destroy a part Name
    ##
    def destroy
      if can?(:>=, "5")
        @part = Kitting::Part.find(params[:id])
        @part.destroy
        respond_to do |format|
          format.html { redirect_to parts_url }
          format.json { head :no_content }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # get the part number from the RBO for lookup
    ##
    def get_part_number
      if can?(:>=, "3")
        @part_numbers = get_part_numbers current_user, params[:part_number].upcase
        if @part_numbers['errMsg'] != ""
          flash.now[:notice] = @part_numbers['errMsg']
        end
        @search_partnumber = @part_numbers
        respond_to do |format|
          format.json {render json: @part_numbers }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action is called by an AJAX action while adding part to a kit. It validates part number in the RBO
    # call and creates a part entry in the table if the part is being searched for the first time.
    ##
    def search
      if can?(:>=, "3")
        if params[:part_type] == "NonContract"
          params[:part_number] = Iconv.conv("UTF-8//IGNORE", "UTF-8",params[:part_number])
          if params[:part_number].present?
            params[:part_number] = params[:part_number].upcase
            @part = Part.find_by_part_number(params[:part_number])
            if @part.present?
              @part.update_attributes(:name => params[:part_name])
              render json: {:part => @part}.to_json
            else
              @part =Part.new(:part_number => params[:part_number], :name => params[:part_name])
              if @part.save
                render json: {:part => @part}.to_json
              end
            end
          end
        else
          params[:part_number] = Iconv.conv("UTF-8//IGNORE", "UTF-8",params[:part_number])
          params[:part_number] = params[:part_number].upcase
          get_part_name_rbo = get_part_numbers current_user, params[:part_number].upcase
          # CHECK FOR RBO RESPONSE
          if get_part_name_rbo.present?
            @custPN = get_part_name_rbo["custPartNoList"] rescue []
            @invPnList = get_part_name_rbo["invPNList"] rescue []
            @primePnList = get_part_name_rbo["primePNList"] rescue []
            @scanCodelist = get_part_name_rbo["scancodeList"] rescue []
            @get_part_name = get_part_name_rbo['partName'] || ""
            # CONDITION TO CHECK IF ANY ERROR MESSAGE IS PRESENT
            if get_part_name_rbo["errMsg"].present? || get_part_name_rbo["errCode"].present?
              @rbo_error = get_part_name_rbo["errMsg"]
              render json: { :error_message => @rbo_error }.to_json
              # CONDITION TO CHECK IF ENTERED PART IS CUSTOMER PART NUMBER
            elsif @custPN.reject(&:blank?).include?(params[:part_number])
              @part = get_cust_pn_from_db params[:part_number]
              if @part.present?
                ##Updating Part Name with the Name as returned by RBO response
                @part.update_attributes(:name => @get_part_name, :prime_pn => @primePnList.first)
                render json: { :part => @part, :image => image_parts_url(:image =>@part.image_name.medium.to_s, :prime_pn => @primePnList.first), :type => "custPN", :part_number_entered => params[:part_number] }.to_json
              else
                @part =Part.new(:part_number => params[:part_number], :name => @get_part_name, :prime_pn => @primePnList.first )
                if @part.save
                  render json: { :part => @part, :image => image_parts_url(:image =>@part.image_name.medium.to_s, :prime_pn => @primePnList.first), :type => "custPN", :part_number_entered => params[:part_number] }.to_json
                end
              end
              #   CONDITION TO CHECK IF ENTERED PART IS INVOICE PN LIST
            elsif @invPnList.reject(&:blank?).include?(params[:part_number])
              index_number = @invPnList.index(params[:part_number])
              cust_PN = customer_part_number index_number,@custPN
              prime_pn = get_prime_pn index_number, @primePnList
              if cust_PN.present?
                @part = get_cust_pn_from_db cust_PN
                if @part.present?
                  ##Updating Part Name with the Name as returned by RBO response
                  @part.update_attributes(:name => @get_part_name,:prime_pn => prime_pn)
                  render json: { :part_number_entered => params[:part_number], :part => @part, :image => image_parts_url(:image =>@part.image_name.medium.to_s), :type => "invPN" }.to_json
                else
                  @part =Part.new(:part_number => cust_PN, :name => @get_part_name,:prime_pn => prime_pn)
                  if @part.save
                    render json: { :image => image_parts_url(:image =>@part.image_name.medium.to_s), :part_number_entered => params[:part_number], :part => @part, :type => "invPN" }.to_json
                  end
                end
              end
              # CONDITION TO CHECK IF ENTERED PART IS IN SCACODE LIST
            elsif @scanCodelist.reject(&:blank?).include?(params[:part_number])
              index_number = @scanCodelist.index(params[:part_number])
              cust_PN = customer_part_number index_number,@custPN
              prime_pn = get_prime_pn index_number, @primePnList
              if cust_PN.present?
                @part = get_cust_pn_from_db cust_PN
                if @part.present?
                  ##Updating Part Name with the Name as returned by RBO response
                  @part.update_attributes(:name => @get_part_name,:prime_pn => prime_pn)
                  render json: { :part_number_entered => params[:part_number], :part => @part, :image => image_parts_url(:image =>@part.image_name.medium.to_s), :type => "scanCodeList" }.to_json
                else
                  @part =Part.new(:part_number => cust_PN, :name => @get_part_name,:prime_pn => prime_pn)
                  if @part.save
                    render json: { :image => image_parts_url(:image =>@part.image_name.medium.to_s), :part_number_entered => params[:part_number], :part => @part, :type => "scanCodeList" }.to_json
                  end
                end
              end
              # CONDITION TO CHECK IF ENTERED PART IS PRIME PART NUMBER
            elsif @primePnList.reject(&:blank?).include?(params[:part_number])
              index_number = @primePnList.index(params[:part_number])
              cust_PN = customer_part_number index_number,@custPN
              cust_PN ||= params[:part_number] # if prime part no matches entered part number and doesnot have any customer part number then mark it as contract part
              prime_pn = get_prime_pn index_number, @primePnList
              if cust_PN.present?
                @part = get_cust_pn_from_db cust_PN
                if @part.present?
                  ##Updating Part Name with the Name as returned by RBO response
                  @part.update_attributes(:name => @get_part_name,:prime_pn => prime_pn)
                  render json: { :part_number_entered => params[:part_number], :part => @part, :image => image_parts_url(:image =>@part.image_name.medium.to_s), :type => "primePN" }.to_json
                else
                  @part =Part.new(:part_number => cust_PN, :name => @get_part_name,:prime_pn => prime_pn)
                  if @part.save
                    render json: { :image => image_parts_url(:image =>@part.image_name.medium.to_s), :part_number_entered => params[:part_number], :part => @part,:type => "primePN" }.to_json
                  end
                end
              end
            else
              @rbo_error = "Part Number Not Found Contact KLX Administrator."
              render json: { :error_message => @rbo_error }.to_json
            end
          else
            @rbo_error = "Service Temporarily Unavailable. "
            render json: {:error_message => @rbo_error }.to_json
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action is for replacing parts in a kit.
    ##
    def replace_parts
      params[:page] = params[:page].nil? ? 1 : params[:page]
      if params[:old_part_number].present? and params[:new_part_number].present?
        if params[:old_part_number].strip == params[:new_part_number].strip
          flash[:error] = "Same Part Numbers cannot be replaced."
        else
          @part_upload = current_customer.kit_bom_bulk_operations.new(:operation_type => "PART REPLACEMENT",:old_part_number => params[:old_part_number].strip,:new_part_number => params[:new_part_number].strip,:status => "PROCESSING")
          if @part_upload.save
            path="#{@part_upload.old_part_number}_#{@part_upload.new_part_number}_#{@part_upload.id}.csv".gsub("/","-")  rescue "Response_#{@part_upload.id}.csv"
            @part_upload.update_attribute("file_path",path)
            begin
              webservice_uri = URI.join(APP_CONFIG['webservice_uri_format'], '/datamigration/replaceParts',{"id" => @part_upload.id.to_s, "custNo" => current_customer.cust_no, "custId" => current_customer.id.to_s,"oldPart" =>@part_upload.old_part_number,"newPart" => @part_upload.new_part_number,:um => params[:new_uom] }.map{ |key, value| "#{key}=#{CGI.escape(value)}" }.join("&").insert(0, "?"))
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
              @data = JSON.parse(@rb_response.body)
            rescue => e
              config.logger.warn "ERROR IN PART REPLACEMENT LINE 235 #{e.backtrace} " rescue "ERROR IN PART REPLACEMENT LINE 235"
              puts e.backtrace
            end
            if @data["errMsg"].nil?
              flash[:success] = @data["successMsg"]
            else
              flash[:error] = @data["errMsg"]
            end
          else
            config.logger.warn "ERROR OCCURED WHILE SAVING PART REPLACEMENT DATA #{@part_upload.errors.inspect}"  rescue "ERROR OCCURED WHILE SAVING PART REPLACEMENT DATA."
            flash[:error] = "Something Went Wrong Contact with your KLX Administrator."
          end
        end
      end
      @part_list=Kitting::KitBomBulkOperation.where(" operation_type = ? and customer_id IN (?) ","PART REPLACEMENT",current_company).paginate(:page => params[:page], :per_page => 100).order('created_at desc')
    end

    ##
    # Searches Part and Removes Special Character from Part Number String and Provides the Image url for the specified part
    ##
    def search_part
      if request.xhr?
        # .......  If OLD PART NO PRESENT ............
        params[:part_number]= Iconv.conv("UTF-8//IGNORE", "UTF-8",params[:part_number])
        if params[:part_status] == "old_part_no"
          @part = Kitting::Part.find_by_part_number(params[:part_number].strip)
          if @part
            if Rails.env == "production" || Rails.env == "qa"
              @img_src = image_parts_url(:image =>@part.image_name_url(:thumb).to_s).gsub("http://","https://")
            else
              @img_src = image_parts_url(:image =>@part.image_name_url(:thumb).to_s)
            end
          end
          # ............. NEW PART NUMBER ...........
        else
          @part = Kitting::Part.find_by_part_number(params[:part_number].strip)
          # If Part is Present In DATABASE ...........
          if @part
            get_part_name_rbo = get_part_numbers current_user, params[:part_number].strip.upcase
            if get_part_name_rbo["errMsg"] == "" and get_part_name_rbo["errCode"]== "" and get_part_name_rbo["searchPartList"].reject(&:blank?).empty?
              if Rails.env == "production" || Rails.env == "qa"
                @img_src = image_parts_url(:image =>@part.image_name_url(:thumb).to_s).gsub("http://","https://")
              else
                @img_src = image_parts_url(:image =>@part.image_name_url(:thumb).to_s)
              end
            else
              @error = get_part_name_rbo["errMsg"]
            end
          else
            # If Part Not Present in Database ...........
            get_part_name_rbo = get_part_numbers current_user, params[:part_number].strip.upcase
            if get_part_name_rbo["errMsg"] == "" and get_part_name_rbo["errCode"]== "" and get_part_name_rbo["searchPartList"].reject(&:blank?).empty?
              @get_part_name = get_part_name_rbo['partName'] || ""
              @part = Part.new(:part_number => params[:part_number], :name => @get_part_name)
              if @part.save
                @info = "Part Validated & Successfully Created , Edit the Part In Part Images Menu."
                if Rails.env == "production" || Rails.env == "qa"
                  @img_src = image_parts_url(:image =>@part.image_name_url(:thumb).to_s).gsub("http://","https://")
                else
                  @img_src = image_parts_url(:image =>@part.image_name_url(:thumb).to_s)
                end
              end
            else
              if get_part_name_rbo["searchPartList"].reject(&:blank?).count > 0
                @error = "Contract Validation Failed. Enter a Valid Part."
              else
                @error = get_part_name_rbo["errMsg"]
              end
            end
          end
        end
      end
    end

    ##
    # Displays Ongoing and Completed Part Replacement Through Excel
    ##
    def part_status
      if can?(:>, "4")
        @part_list = Kitting::KitBomBulkOperation.where(" operation_type = ? and customer_id IN (?) ","PART REPLACEMENT",current_company).paginate(:page => params[:page], :per_page => 100).order('created_at desc')
      else
        redirect_to main_app.unauthorized_url
      end
    end
    # Checks Part Cupo Count Upload Status
    def part_count_status
      if can?(:>, "4")
        @part_uploads = Kitting::KitBomBulkOperation.where(" operation_type = ? and customer_id IN (?) ","PART CUP COUNT",current_company).paginate(:page => params[:page], :per_page => 100).order('created_at desc')
      else
        redirect_to main_app.unauthorized_url
      end
    end

    # Importing CSV Files for Updating Part Cup Count !!!
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
        @part_cup_count_upload = current_customer.kit_bom_bulk_operations.create(:operation_type => "PART CUP COUNT",:file_path => name,:status => "UPLOADING")
        directory = APP_CONFIG["csv_import_path"]
        file_path = repeat == 0 ?  name : "#{name}(#{repeat-1})"
        if @part_cup_count_upload.update_attributes(:file_path => file_path,:status => "UPLOADED")
          path = File.join(directory, file_path)
          @file_status = File.open(path, "wb") { |f| f.write(params[:kit_bom_bulk_operation][:file].read) }
          if File.exists?(File.join(directory,@part_cup_count_upload.file_path))
            # Check if Header present and is in correct format
            csv_text = File.read(File.join(directory,@part_cup_count_upload.file_path))
            header = CSV.parse_line(csv_text)
            if header == ["PART NUMBER", "LARGE CUP COUNT", "MEDIUM CUP COUNT", "SMALL CUP COUNT"]
              flash[:success] = "File Uploaded and will be processed Shortly."
              redirect_to upload_parts_path
            else
              flash[:error] = "INVALID HEADERS/DOWNLOAD SAMPLE CSV FOR HEADER FORMAT."
              FileUtils.rm_rf File.join(directory,@part_cup_count_upload.file_path)
              @part_cup_count_upload.destroy
              redirect_to upload_parts_path
            end
          else
            flash[:error] = "INVALID FILE FORMAT."
            @part_cup_count_upload.destroy
            redirect_to upload_parts_path
          end
        else
          flash[:error] = "INVALID FILE FORMAT."
          @part_cup_count_upload.destroy
          redirect_to upload_parts_path
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end
    # EXPORT RESPONSE/PROCESSED CSV FILE
    def csv_export
      if can?(:>, "4")
        directory= APP_CONFIG["csv_export_path"]
        @record = KitBomBulkOperation.find_by_id(params[:id])
        export_path="Response_#{@record.id}_cup_count_#{@record.file_path.gsub(".csv","")}.csv"
        if File.exist?(File.join(directory,export_path))
          send_file File.join(directory,export_path), :disposition => "attachment"
        else
          flash[:error] = "Something went Wrong Response File Not Found/Try Uploading a New File."
          redirect_to upload_parts_path
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    # Upload GUI for Part Cup Count in CSV Format
    def upload
      if can?(:>, "4")
        params[:page] = params[:page].nil? ? 1 : params[:page]
        @part_upload = Kitting::KitBomBulkOperation.new
        @part_uploads = Kitting::KitBomBulkOperation.where("operation_type = ? and customer_id IN (?)","PART CUP COUNT",current_company).paginate(:page => params[:page], :per_page => 100).order('created_at desc')
      else
        redirect_to main_app.unauthorized_url
      end
    end
    # Download Samppe Part Upload CSV File
    def download_sample
      if can?(:>, "4")
        send_file Rails.public_path+"/excel/Import/sample_file_part_upload.csv", :disposition => "attachment"
      else
        redirect_to main_app.unauthorized_url
      end
    end

    private

    def get_cust_pn_from_db cust_part_no
      Part.find_by_part_number(cust_part_no)
    end

    def get_prime_pn index_number, primePnList
      primePnList[index_number].present? ? primePnList[index_number] : primePnList.first
    end
  end
end