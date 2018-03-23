require_dependency "kitting/application_controller"
#  Extension for Kits Controller i.e extended methods of kits controller Goes here
module Kitting
  class KitDetailsController < ApplicationController
    before_filter :add_headers, :only=>[ :download_kit_copy_rfid]
    # Lists Bin Center and allows user to enter part number with Kit Number to Download BOM
    def index
      if can?(:>=, "4")
        params[:page] = params[:page].nil? ? 1 : params[:page]
        @binCenters_response = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
        @binCenters = []
        @binCenters_response['binCenterList'].each do |i|
          @binCenters << i
        end
        #@status = current_customer.kit_bom_bulk_operations.where("is_downloaded = ? and operation_type = ? and status =? ",false,"BOM DOWNLOAD","PROCESSING")
        respond_to do |format|
          format.html { }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    # Creates a Entry in KIT BOM BULK OPERATION and Invokes webservice to Get list of Kits matching Criteria and Download it to End Users
    def create
      #if params[:kit_number].present? or params[:part_number].present? or params[:bincenter].present?
      @bom = current_customer.kit_bom_bulk_operations.new(:operation_type => "BOM DOWNLOAD",:part_number => params[:part_number].strip,:bin_center => params[:bincenter].strip,:kit_number => params[:kit_number].strip,:status => "PROCESSING")
      if @bom.save
        if params[:kit_number].present? or params[:part_number].present? or params[:bincenter].present?
          path="#{@bom.kit_number.present? ? (@bom.kit_number.to_s + "_" + @bom.id.to_s ) : (@bom.part_number.present? ? @bom.part_number.to_s + "_" + @bom.id.to_s : "BIN_CENTER_" + @bom.bin_center.to_s + "_" + @bom.id.to_s )  }.csv".gsub("/","-")  rescue "Response_#{@bom.id}.csv"
        else
          path = "ALL_KIT_#{current_user}_#{@bom.id}.csv".gsub("/","-")
        end
        @bom.update_attribute("file_path",path)
        config.logger.warn "BOM RECORD CREATED #{@bom.inspect},#{__FILE__}, #{__LINE__}." rescue "ERROR WHILE LOGGING BOM DATA"
        begin
          webservice_uri = URI.join(APP_CONFIG['webservice_uri_format'], '/datamigration/download/kits',{"id" => @bom.id.to_s, "custNo" => current_user, "custId" => current_customer.id.to_s,"kitNo" =>@bom.kit_number,"partNo" => @bom.part_number,:binCenter => @bom.bin_center }.map{ |key, value| "#{key}=#{CGI.escape(value)}" }.join("&").insert(0, "?"))
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
          puts e.backtrace
        end
        @data = JSON.parse(@rb_response.body)
        if @data.present?
          if @data["errMsg"].nil?
            session["BOM_ID"]= @bom.id
            @rbo_success = @data["successMsg"]
          else
            config.logger.warn "WEB SERVICE ERROR WHILE GENERATING BOM DATA FOR #{__FILE__}, #{__LINE__},#{@bom.inspect},#{@rb_response.body }." rescue "WEB SERVICE ERROR FOR RESPONSE BODY."
            @bom.destroy
            @rbo_error = @data["errMsg"]
          end
        else
          config.logger.warn "WEB SERVICE ERROR WHILE GENERATING BOM DATA FOR #{@bom.inspect}." rescue "WEB SERVICE ERROR."
          @bom.destroy rescue "ERROR DESTROYED RECORD"
          config.logger.warn "WEB SERVICE ERROR WHILE GENERATING BOM DATA."
          @rbo_error = "CANNOT CONNECT TO WEB SERVICES TRY LATER OR CONTACT KLX ADMINISTRATOR"
        end
      else
        config.logger.warn "ERROR OCCURED WHILE GENERATING BOM DOWNLOAD DATA #{@bom.errors.inspect}"  rescue "ERROR OCCURED WHILE GENERATING BOM DOWNLOAD DATA."
        @rbo_error = "Something Went Wrong Contact with your KLX Administrator."
      end
      #else
      #	@validation_error = "Please enter Kit Number/Part Number/Bin Center to Download BOM Report."
      #end

    end

    def download_kit_copy_rfid
      if can?(:>, "4")
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = "attachment; filename=Newly Designed Kits Report.xls"
        headers['Cache-Control'] = ''

        # code to create xls file
        require 'writeexcel'
        workbook = WriteExcel.new(Rails.public_path+"/excel/Kit Copy RFID Serial Number Report.xls")
        worksheet  = workbook.add_worksheet("rfid_serial_number")

        format = workbook.add_format
        border = workbook.add_format
        header = workbook.add_format

        format.set_bold
        border.set_bottom(1)
        header.set_bold
        header.set_header('Big')


        @row_value = 0
        @col_value = 0
        # create a table in xls file

        worksheet.set_column(0, 0, 20)
        worksheet.set_column(0, 1, 20)
        worksheet.set_column(0, 2, 20)
        worksheet.set_column(0, 3, 20)
        worksheet.set_column(0, 4, 30)
        worksheet.set_column(0, 5, 30)

        worksheet.write(@row_value, 0,"Kit Part Number",format)
        worksheet.write(@row_value, 1,"Kit Copy Number",format)
        worksheet.write(@row_value, 2,"Kit Bin Center",format)
        worksheet.write(@row_value, 3,"Customer No", format)
        worksheet.write(@row_value, 4,"Kit Media Type Description",format)
        worksheet.write(@row_value, 5,"RFID Serial number",format)

        if params[:kit_copy_number].present? && params[:rfid_number].present?
          @kit_copies = Kitting::KitCopy.where("kit_version_number LIKE ? and rfid_number LIKE ? and customer_id IN (?)","%#{params[:kit_copy_number].upcase}%","%#{params[:rfid_number]}%",current_company).order('kit_version_number')
        elsif params[:kit_copy_number].present?
          @kit_copies = Kitting::KitCopy.where("kit_version_number LIKE ? and customer_id IN (?)","%#{params[:kit_copy_number].upcase}%",current_company).order('kit_version_number')
        elsif params[:rfid_number].present?
          @kit_copies = Kitting::KitCopy.where("rfid_number LIKE ? and customer_id IN (?)","%#{params[:rfid_number]}%",current_company).order('kit_version_number')
        else
          @kit_copies = Kitting::KitCopy.where("customer_id IN (?)",current_company).order('kit_version_number')
        end
        @kit_copies.each_with_index do |kit_copy|
          if kit_copy.blank?
            "Not Available"
          else
            @row_value = @row_value + 1
            worksheet.write(@row_value,0,kit_copy.kit.kit_number)
            worksheet.write(@row_value,1,kit_copy.kit_version_number)
            worksheet.write(@row_value,2,kit_copy.kit.bincenter)
            worksheet.write(@row_value,3,kit_copy.kit.cust_no)
            worksheet.write(@row_value,4,kit_copy.kit.kit_media_type.name)
            worksheet.write_string(@row_value,5,kit_copy.rfid_number)
            @row_value = @row_value+0
            worksheet.write(@row_value, border)
          end
        end
        workbook.close
        send_file(Rails.public_path+"/excel/Kit Copy RFID Serial Number Report.xls",:disposition => "attachment")
      else
        redirect_to main_app.unauthorized_url
      end
    end

    #  Display the Kit BOM BUlk Operation Details.
    def show
      @bom_data = Kitting::KitBomBulkOperation.find_by_id(params[:id])
    end

    def store_selected_cup_ids
      case params[:label_for]
        when "kits"
          session[:cup_ids] ||= []
          params[:cup_id] = params[:cup_id].to_i
          if params[:checked] == "true"
            session[:cup_ids] << params[:cup_id]
          else
            session[:cup_ids].delete(params[:cup_id])
          end
          render :json => {"status" => "Success"}
        when "kit_copies"
          session[:copy_cup_ids] ||= []
          params[:cup_id] = params[:cup_id].to_i
          if params[:checked] == "true"
            session[:copy_cup_ids] << params[:cup_id]
          else
            session[:copy_cup_ids].delete(params[:cup_id])
          end
          render :json => {"status" => "Success"}
        when "pick_ticket"
          session[:pick_selected_cups] ||= []
          if params[:checked] == "true"
            session[:pick_selected_cups] << params[:cup_id]
          else
            session[:pick_selected_cups].delete(params[:cup_id])
          end
          render :json => {"status" => "Success"}
        else
          render :json => {"status" => "Failure"}
      end
    end

    def get_kit_parts_count
      if request.xhr?
        @kit = Kitting::Kit.find_by_kit_number_and_commit_id(params[:kit_detail_id],nil)
        query = Proc.new { |object| object.cups.where(:status => true).select {|c| c.cup_parts if c.cup_parts.find_all_by_status(true).size > 0}.count > 0 }
        if @kit.kit_media_type.kit_type == "multi-media-type"
          @orig_mmt_kits = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(@kit.id, false)
          status = @orig_mmt_kits.map{ |kit| query.call(kit)}
          box = status.index(false) + 1 if status.include?(false)
          status = !status.include?(false)
        else
          status = query.call(@kit)
        end
        render :json => {"status" => status,:box => box || nil }
      end
    end
  end
end