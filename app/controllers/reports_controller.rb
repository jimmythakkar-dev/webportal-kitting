class ReportsController < ApplicationController
  before_filter :get_menu_id
  before_filter :add_headers, :only=>[:download]

  ##
  # This action is of index page (front page when someone
  #   clicked on Reports link)
  # Showing report list as per current user
  #   (used default @files object)
  ##
  def index
    @directory_path = APP_CONFIG['conversion_report_path']
    @filter_name = current_user + "*.*"
    #Checking whether the specified directory exists
    if Report.directory_exists?(@directory_path)
      @files = Dir.glob("#{@directory_path}#{@filter_name}")
      @files = @files.sort do |a,b| a.upcase <=> b.upcase end
      #If directory does not exists
    else
      flash.now[:notice] =  I18n.translate("directory_doesnot_exist",:scope => "reports.index")
    end
    @manual_files = Report.where(:cust_no => current_user)
    #End of Checking whether the specified directory exists
    render :index
  end

  ##
  # This action is to download reports from specified directory path
  ##
  def download
    if params[:file]
      @directory_path = APP_CONFIG['conversion_report_path']
      @file_name = params[:file]
    elsif params[:report]
      @directory_path = APP_CONFIG['conversion_report_path']
      if params[:report] == "custfo"
        if can?(:>=,"2")
          @file_name = Report.get_file_name(params[:report], current_user)
          @display_name = @file_name.split("_").last
        else
          redirect_to unauthorized_url
        end
      else
        @file_name = Report.get_file_name(params[:report], current_user)
        @display_name = @file_name.split("_").last
      end
    end
    if params[:type] == "manual"
      send_file @file_name,:filename => @display_name, :disposition => "attachment"
    else
      send_file "#{@directory_path}#{@file_name}",:filename => @display_name, :disposition => "attachment"
    end
  end

  ##
  # This action is to generate reports through RBO call
  # RBO will generate reports in server path
  ##
  def generate
    case params[:report_generate]
      #Webservice call for generating Bin Map Report
      when "binmapgen"
        @response_report = invoke_webservice method: 'get', class: 'report/',
                                             action: 'binStockItem',
                                             query_string: { custNo: current_user}
        if @response_report
          if @response_report["errCode"] == "1"
            flash[:notice] = @response_report["errMsg"]
          end
        else
          flash[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
      #Webservice call for generating Consignment Inventory Report
      when "consiggen"
        @response_report = invoke_webservice method: 'get', class: 'report/',
                                             action: 'blmtGroup',
                                             query_string: { custNo: current_user}
        if @response_report
          if @response_report["errCode"] == "1"
            flash[:notice] = @response_report["errMsg"]
          end
        else
          flash[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
      #Webservice call for generating On Hand Report
      when "onhandgen"
        @response_report = invoke_webservice method: 'get', class: 'report/',
                                             action: 'boeingWeeklyMaterial',
                                             query_string: { custNo: current_user}
        if @response_report
          if @response_report["errCode"] == "1"
            flash[:notice] = @response_report["errMsg"]
          end
        else
          flash[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
      #Webservice call for generating Open Orders Report
      when "openorgen"
        @response_report = invoke_webservice method: 'get', class: 'report/',
                                             action: 'openOrder',
                                             query_string: { custNo: current_user}
        if @response_report
          if @response_report["errCode"] == "1"
            flash[:notice] = @response_report["errMsg"]
          end
        else
          flash[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
      #Webservice call for generating Empties Report
      when "emptiegen"
        @response_report = invoke_webservice method: 'get', class: 'report/',
                                             action: 'openOrderEmpties',
                                             query_string: { custNo: current_user}
        if @response_report
          if @response_report["errCode"] == "1"
            flash[:notice] = @response_report["errMsg"]
          end
        else
          flash[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
      when "binactgen"
        #Webservice call for generating Cust Forecast Reports
      when "custfogen"
        if can?(:>=, "2")
          @response_report = invoke_webservice method: 'get', class: 'report/',
                                               action: 'custForecast',
                                               query_string: { custNo: current_user}
        end
        if @response_report
          if @response_report["errCode"] == "1"
            flash[:notice] = @response_report["errMsg"]
          end
        else
          flash[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
      #Webservice call for generating Past Due Reports
      when "pastdugen"
        @response_report = invoke_webservice method: 'get', class: 'report/',
                                             action: 'pastDue',
                                             query_string: { custNo: current_user}
        if @response_report
          if @response_report["errCode"] == "1"
            flash[:notice] = @response_report["errMsg"]
          end
        else
          flash[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
      #Webservice call for generating QC Lab Reports
      when "qclabgen"
        @response_report = invoke_webservice method: 'get', class: 'report/',
                                             action: 'trackingReport',
                                             query_string: { custNo: current_user}
        if @response_report
          if @response_report["errMsg"] != ""
            flash[:notice] = @response_report["errMsg"]
          end
        else
          flash[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
    end
    redirect_to reports_path
  end

  def upload
    if can?(:>=, "5")
      if request.post?
        @report = Report.new(:cust_no => current_user,:name => params[:file].original_filename, :file_name => params[:file],:description => params[:description],:uploaded_by => current_user)
        if @report.save
          flash[:notice] = "Report Uploaded Successfully" unless request.xhr?
          respond_to do |format|
            format.html { redirect_to reports_path }
            format.js { render :json => @report.to_json }
            format.json { render :json => @report.to_json }
          end
        else
          flash[:error] = @report.errors.try(:messages).try(:values).try(:flatten).join(",") rescue "File Upload Unsuccessful" unless request.xhr?
          respond_to do |format|
            format.html { redirect_to reports_path }
            format.js {}
            format.json {}
          end
        end
      end
    else
      redirect_to unauthorized_url
    end
  end

  def destroy
    if can?(:>=, "5")
      @report = Report.find_by_id(params[:id])
      if @report.present?
        @report.destroy
        flash[:notice] = "Report Destroyed Successfully"
      else
        flash[:error] = "No Report Found"
      end
      respond_to do |format|
        format.html { redirect_to reports_path }
        format.js {render :nothing =>  true}
      end
    else
      redirect_to unauthorized_url
    end
  end
end