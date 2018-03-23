class CertsController < ApplicationController
  include ApplicationHelper
  before_filter -> { get_menu_id params }
  layout "kitting/fit_to_compartment", :only => [:view_certs]
  ##
    # This action is of index page (front page when someone
    #   clicked on View Certification link)
  ##
  def index

  end

  ##
    # This action is to show certificates result page,
    #   based on control number entered on search box
    # If session["acct_switch"] contain more than 2 values,
    #   it displays certificates for each customer
  ##
  def search
    if params[:stock_transfer] && params[:control_number_stock]
      control_number = params[:control_number_stock].try(:strip).try(:upcase)
      stock_transfer = params[:stock_transfer].try(:strip).try(:upcase)
      customer_number = current_customer.cust_no
      @response_stock_certs = invoke_webservice method: 'get',
                                            action: 'imageNames',
                                            query_string: { controlNo: control_number,
                                                            stockTransfer: stock_transfer,
                                                            custNo: customer_number,
                                                            pckFlag: "0",
                                                            invoiceNo: ""
                                                          }
      if @response_stock_certs
        if @response_stock_certs["errMsg"] != ""
          flash.now[:notice] = "Error Message:"+ @response_stock_certs["errMsg"]
        end
      else
        flash.now[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
      end
      render :index_stock
    else
      control_number = params[:control_number].try(:strip).try(:upcase)
      pack_flag = "0"
      error_messages_array = []
      @array_for_certs_details = []
      if session["acct_switch"].length >= 2
        session["acct_switch"].each_with_index do |customer_number, index_of_control|
          @response_certs = invoke_webservice method: 'get',
                                action: 'imageNames',
                                query_string: { controlNo: control_number,
                                custNo: customer_number,
                                pckFlag: pack_flag
                                }
          if @response_certs
            if @response_certs["errMsg"] != ""
              if error_messages_array.blank?
                error_messages_array = "Account: #{customer_number} - #{@response_certs["errMsg"]}</br>"
              else
                error_messages_array = error_messages_array << "Account: #{customer_number} - #{@response_certs["errMsg"]}</br>"
              end
              flash.now[:notice] = error_messages_array
            else
              @hash_for_certs = {}
              @response_certs["controlNo"].each_with_index do |value, index|
                @hash_for_certs = Hash["images",@response_certs["images"][index],"imagesFullPath",@response_certs["imagesFullPath"][index],"partNo",@response_certs["partNo"][index],"desc",@response_certs["desc"][index],"controlNo",@response_certs["controlNo"][index],"customer_number",customer_number]
                @array_for_certs_details << @hash_for_certs
              end
            end
          else
            flash.now[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
          end
        end
      else
        @response_certs = invoke_webservice method: 'get',
                                 action: 'imageNames',
                                 query_string: { controlNo: control_number,
                                 custNo: current_user,
                                 pckFlag: pack_flag
                                 }
        if @response_certs
          if @response_certs["errMsg"] != ""
            flash.now[:notice] = "Account: #{current_user} - #{@response_certs["errMsg"]}"
          else
            @hash_for_certs = {}
            @response_certs["controlNo"].each_with_index do |value, index|
              @hash_for_certs = Hash["images",@response_certs["images"][index],"imagesFullPath",@response_certs["imagesFullPath"][index],"partNo",@response_certs["partNo"][index],"desc",@response_certs["desc"][index],"controlNo",@response_certs["controlNo"][index],"customer_number",current_user]
              @array_for_certs_details << @hash_for_certs
            end
          end
        else
          flash.now[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
      end
      render :index
    end
  end

  ##
    # This action is to show certificates in PDF format with watermark of text "B/E AEROSPACE",
    #   based on selected control number and customer
  ##

  def view_certs
    @control_number = params[:control_number]
    @directory_path = APP_CONFIG['certification_path']
    if params[:images].class == String
      @array_of_images = params[:images].split(" ")
    else
      @array_of_images = params[:images]
    end
    @public_path = File.expand_path("#{Rails.root}/private/certificates")
    @files_array = []
    @source_image_array = []
    if Report.directory_exists?(@directory_path)
      unless @array_of_images.blank?
        @array_of_images.each_with_index do |image, index|
          if Report.file_exists?(@directory_path+image)
            source_image = @directory_path+image
            @source_image_array << source_image
          else
            flash.now[:notice] = "Source path <br /><br /> #{@directory_path+image}<br /> <br />does not exist.".html_safe
          end
        end
      end
    end
    unless @source_image_array.blank?
      FileUtils.mkdir_p("#{@public_path}/#{params[:control_number]}")
      convert_image = "#{@public_path}/#{params[:control_number]}"
      %x(convert -limit area 1  "#{@source_image_array.join(',').gsub(',','" "')}" -compress jpeg  -gravity Center -draw 'image SrcOver 30,10 800,600 "#{Rails.root}/app/assets/images/KLX-Logo-Aerospace-Gray.png"' "#{convert_image}/#{params[:control_number]}.pdf")
      if Report.directory_exists?("#{@public_path}/#{params[:control_number]}/")
        #Fixing  undefined method `pdf' for string
        if Report.file_exists?("#{@public_path}/#{params[:control_number]}/#{params[:control_number]}.pdf")
          respond_to do |format|
            format.html do
              send_file "#{@public_path}/#{params[:control_number]}/#{params[:control_number]}.pdf",
                    :type => 'application/pdf', :disposition => 'inline'
            end
          end
        end
      end
    end
  end

  def index_stock
  end

  #def search_stock
  #  render :index_stock
  #end
  #
  #def view_stock
  #
  #end
end