require 'RMagick'
class ApplicationController < ActionController::Base

=begin
 Every Incoming Requests Process through this Controller

Method Names and its Uses:

authenticate: Authenticates User and its Logged in session in every incoming request and responses
set_cache_buster: Sets Cache Buster, i.e disables browser cache
set_user_language: Sets User language defaults to :english(en)
current_user: Returns Currently Logged in User(029540)
current_customer: Returns the Records of Currently Logged in User
invoke_webservice: Ruby Webservice to Invoke external Webservice through NET:HTTP& Open-URI
current_company:Returns list of Users Array within same Customer no. e.g [10001,10005,10008]
bom_data: Sets BOM ID of Ongoing Bulk Download/Uploads to System
error_mail_notifier_webservice: Sends Error mail Notification to admin users through mule web services.
*_access: Defines Level Access (RMA/AGUSTA)
get_menu_id: Checks for Access for a particular menu_description.
can? : Checks if a User has access to a incoming request/response
add_headers: Adds Public Headers to Download excel Sheets without causing error in earlier versions of IE (6,7,8)

=end

  before_filter :authenticate
  before_filter :set_cache_buster, :set_user_language
  helper_method :current_user,:current_customer, :invoke_webservice,:current_company,:bom_data,:set_user_language

  protect_from_forgery

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception,:with => :rescue_not_found
    rescue_from ActiveRecord::RecordNotFound ,:with => :rescue_not_found
    rescue_from ActiveRecord::RecordInvalid ,:with => :rescue_not_found
    rescue_from ActionController::UnknownController,:with => :rescue_not_found
    rescue_from ActionController::UnknownAction,:with => :rescue_not_found
    rescue_from ActionController::InvalidAuthenticityToken,:with => :rescue_not_found
    rescue_from AbstractController::ActionNotFound,:with => :rescue_not_found

    protected

    # Method to display a detailed explanation of error report in GUI and Mailing System(through Rbo Calls)
    def rescue_not_found(exception)
      request_url = request.env["REQUEST_URI"]
      err_head = exception.message
      err_details = exception.backtrace.first(10).join("\n")
      user_name = session[:user_name]
      request_details = request.inspect rescue ""
      @data_send = error_mail_notifier_webservice method: 'post', action: 'sendErrorMail', data: "User that encountered the error: #{user_name} \n Application Version: #{APP_VERSION} \n Browser: #{browser.to_s} \n Requested URL: #{request_url} \n Error : #{err_head} \n Trace : #{err_details} \n Request Details: #{request_details}"
      config.logger.error "Time of error occurrence #{Time.now} "
      config.logger.error "URL : #{request_url} \nError Encountered : #{err_head} \nDetails : #{err_details} \nRequest Details: #{request_details} \n --------------------------------"
      render :template => "/errors/500.html.erb",:locals => {:error => err_head }
    end

    # Method to display a detailed explanation of routing error report in GUI and Mailing System(through Rbo Calls)
    def rescue_no_route(message_hash)
      @data_send = error_mail_notifier_webservice method: 'post', action: 'sendErrorMail', data: "User that encountered the error : #{message_hash[:user]} \n Application Version: #{APP_VERSION} \n Browser: #{browser.to_s} \n Requested URL: #{message_hash[:request]} \n Message : #{message_hash[:message]}"
      render :template => "/errors/404.html"
    end
  end

  private

  def rma_access
    redirect_to unauthorized_url if can?(:<,"5")
  end

  def agusta_access
    redirect_to unauthorized_url if can?(:>,"3")
  end

  def set_user_language
    #if params[:controller] == "panstock_requests" || params[:controller] == "floor_views" || params[:controller] == "bin_line_station" || params[:controller] == "agusta"|| params[:controller] == "critical_watch" || params[:controller] == "supersedence" || params[:controller] == "certs"
    I18n.locale =  session[:language].nil? ? :en : session[:language]
    #else
    #  I18n.locale= :en
    #end
  end

  def current_user
    @current_user ||= session[:customer_number] if session[:customer_number]
  end

  def current_customer
    @current_customer ||= Kitting::Customer.find_by_user_name_and_user_level_and_cust_no(session[:user_name],session[:user_level],current_user) if session[:customer_Name]
  end

  def current_company
    @current_company = Kitting::Customer.find_all_by_cust_no(current_user).map(&:id)
  end

  def current_vendor
    @current_vendor ||= Kitting::Customer.find_by_user_name_and_user_level_and_vendor_no(session[:user_name],session[:user_level],session[:vendor_number]) if session[:customer_Name]
  end

  def authenticate
    if current_user.nil? or current_customer.nil?
      if current_vendor.blank?
        reset_session
        redirect_to login_url
      end
    end
  end

  def bom_data
    @data = session["BOM_ID"]
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  # Method to invoke web-services
  # Eg GET method invoke_webservice method: 'get', class: 'custInv/',
  #                 action: 'binCenters', query_string: { custNo: session[:customer_number] }
  # Eg POST method invoke_webservice method: 'post',
  #                  action: 'userLogin', data: { userName: params[:username],
  #                  password: params[:password] }
  #                  action: 'binCenters', query_string: { custNo: session[:customer_number] })
  def invoke_webservice url
    query_string = url[:query_string].blank? ? "" : url[:query_string].map{ |key, value|
      "#{key}=#{CGI.escape(value)}" }.join("&").insert(0, "?")
    url[:class] = url[:class].blank? ? "" : url[:class]
    webservice_uri = URI.join(APP_CONFIG['webservice_uri_format'], '/application/',
                              url[:class], url[:action], query_string)
    uri = URI.parse(webservice_uri.to_s)
    http = Net::HTTP.new(uri.host, uri.port)
    if APP_CONFIG['webservice_uri_format'].include?("https")
      http.use_ssl = true
      http.verify_mode =  OpenSSL::SSL::VERIFY_NONE
    end
    http.open_timeout = 25
    http.read_timeout = 500
    http.start do |http|
      if url[:method] == 'get'
        request = Net::HTTP::Get.new(uri.request_uri)
      else
        request = Net::HTTP::Post.new uri.path, initheader = { 'Content-Type' => 'application/json' }
        request.body = url[:data].to_json
      end
      request.basic_auth APP_CONFIG['username'], APP_CONFIG['password']
      response = http.request request
      JSON.parse(response.body) if response.code =~ /^2\d\d$/
    end
  rescue => e
    puts "Error Message is #{e.inspect} #{e.backtrace}"
  end

  def error_mail_notifier_webservice url
    query_string = url[:query_string].blank? ? "" : url[:query_string].map{ |key, value|
      "#{key}=#{CGI.escape(value)}" }.join("&").insert(0, "?")
    url[:class] = url[:class].blank? ? "" : url[:class]
    webservice_uri = URI.join(APP_CONFIG['webservice_uri_format'], '/application/',
                              url[:class], url[:action], query_string)


    uri = URI.parse(webservice_uri.to_s)
    http = Net::HTTP.new(uri.host, uri.port)
    if APP_CONFIG['webservice_uri_format'].include? "https"
      http.use_ssl = true
      http.verify_mode =  OpenSSL::SSL::VERIFY_NONE
    end
    http.open_timeout = 10
    http.read_timeout = 200
    http.start do |http|
      if url[:method] == 'get'
        request = Net::HTTP::Get.new(uri.request_uri)
      else
        request = Net::HTTP::Post.new uri.path, initheader = { 'Content-Type' => 'text/plain' }
        request.body = url[:data]
      end
      request.basic_auth APP_CONFIG['username'], APP_CONFIG['password']
      response = http.request request
      (response.body) if response.code =~ /^2\d\d$/
    end
  rescue => e
    puts "Error Message is #{e.inspect} #{e.backtrace}"
  end

  def get_menu_id(args= {})
    if session[:menu_description].blank?
      redirect_to unauthorized_url
    else
      if args[:web_order_type] == "Sikorsky"
        redirect_to unauthorized_url  unless session[:menu_description].any? {|w| w =~ /#{AUTH_CONFIG["sikorsky"]}/}
      elsif args[:certs_type] == "StockCerts"
        redirect_to unauthorized_url  unless session[:menu_description].any? {|w| w =~ /#{AUTH_CONFIG["stock_certs"]}/}
      else
        redirect_to unauthorized_url  unless session[:menu_description].any? {|w| w =~ /#{AUTH_CONFIG[params[:controller]]}/}
      end
    end
  end

  def can?(condition,level)
    if session[:user_level].blank?
      return false
    else
      if session[:user_level].send(condition, level)
        return true
      else
        return false
      end
    end
  end

  def adhoc_kit_access?
    customer = Kitting::CustomerConfigurations.where(:cust_no => current_user)
    if customer.present? && customer.first.kitting_type == "AD HOC"
      return true
    else
      return false
    end
  end

  def add_headers
    response.headers['Pragma'] = 'cache'
    response.headers['Cache-Control'] = 'public, must-revalidate, max-age=0'
  end

  # Fills out Search list In Inquiry Search page
  def fill_search_list
    @date_range = Order.date_range
    @search_code = Order.search_code
    @order_status = Order.order_status
    @order_source = Order.order_source
    users = invoke_webservice method: 'get', action: 'users', query_string: {custNo: current_user} if params[:controller] == "agusta"
    userslist = users["webUserList"] rescue []
    @order_uname = Order.uname(userslist)
  end

end