class UserSessionsController < ApplicationController
  skip_before_filter :authenticate
  include ApplicationHelper
  layout = 'sign_in'

  # change in session[]language] according to the selected language
  def change_user_lang
    session[:language] = params[:lang]
    render :json => {:controller => params[:controller_name]}
  end

  # at tha login page application is not needed
  def new
    render layout: false
  end

  # render new form for reset password
  def new_reset_password
  end

  # post reset password form to RBO
  def reset_password
    response = invoke_webservice method: 'post', action: 'resetPassword',
                                 data: { userId:        params[:user_name],
                                         oldPassword:   params[:current_password],
                                         newPassword1:  params[:new_password],
                                         newPassword2:  params[:confirm_password],
                                         pswdChangeFlag:"1",
                                         uidCheckFlag:  "1" }
    if response
      if response["errMsg"].blank? && !response["successMsg"].blank?
        reset_session
        flash.now[:notice] = I18n.t(response["successMsg"],:scope => "user_session",:default => response["successMsg"] )
        render :login
      else
        flash.now[:error] = I18n.t(response["errMsg"],:scope => "user_session",:default => response["errMsg"] )
        render 'new_reset_password'
      end
    else
      flash.now[:error] = I18n.t("no_service",:scope => "user_session" )
    end
  end

  # once username and password entered correctly it will stores the response in session variables
  def create
    response = invoke_webservice method: 'post',
                                 action: 'userLogin', data: { userName: params[:username].upcase.strip,
                                                              password: params[:password] }
    if response
      if response["errCode"] == "0"
        if response["userType"] == "C" || response["userType"] == "E" || response["userType"] == "V" || response["userType"] == "P"
          session[:full_name] = response["fullName"]
          session[:user_level] = response["userLevel"]
          session[:buyer_email] = response["buyerEmail"]
          session[:order_flag] = response["orderFlag"]
          session[:user_name] = response["userName"]
          session[:acct_switch] = response["acctSwitch"]
          session[:user_type] = response["userType"]
          session[:password_lock] = response["passwordLock"]
          session[:vendor_number] = response["vendNo"]
          session[:partner_number] = response["partnerNo"]
          session[:multorder] = response["multOrder"]
          session[:autoApprove] = response["autoApprove"]
          #Ecom Menu
          session[:menu_description] = response["menuDesc"]

          #CUSTOMER

          session[:customer_number] = response["custNo"]
          session[:customer_Name] = response["custName"]
          session[:contact] = response["contact"]
          session[:phone_number] = response["phoneNo"]


          #SLSMAN
          session[:slsm_email] = response["slsmEmail"]
          session[:slsm_name] = response["slsmName"]
          session[:slsm_phone] = response["slsmPhone"]
          session[:slsm_fax]  = response["slsmFax"]
          session[:language] = response["custDefaultLang"].present? ? response["custDefaultLang"].downcase : "en"
          #F.ACC.TYPE FILE VARS
          session[:customer_type] = response["custType"]
          if session[:acct_switch].length > 1 && session[:acct_switch].first!= "" && session[:acct_switch].first!= " "
            @account_switcher_array = []
            session[:acct_switch].each do |value|
              @response_ship_to = invoke_webservice method: 'get', class: 'custInv/',
                                                    action: 'shipTo',
                                                    query_string: { custNo: value }
              if @response_ship_to
                if @response_ship_to["errMsg"] != ""
                  customer_name = "#{value} #{session[:customer_Name]}"
                  @account_switcher_array = @account_switcher_array.push(customer_name)
                else
                  customer_name = "#{value} #{@response_ship_to["custInfo"].split("<BR>").second}"
                  @account_switcher_array = @account_switcher_array.push(customer_name)
                end
              end
            end
            session[:account_switcher_array] = @account_switcher_array
          end
          # Populate New Customer into DB
          @customer_record = Kitting::Customer.find_by_user_name_and_user_level(response["userName"],response["userLevel"]) || Kitting::Customer.create( :cust_no => response["custNo"], :cust_name => response["custName"], :user_name => response["userName"], :user_level =>response["userLevel"], :user_type => response["userType"], :accounts => response["acctSwitch"].join(","), :vendor_no => response["vendNo"], :partner_no => response["partnerNo"] )
          Kitting::CustomerConfigurations.find_or_create_by_cust_no(cust_no: response["custNo"],cust_name: response["custName"],updated_by: @customer_record.id )
          if response["vendNo"].present?
            @customer_record.update_attribute("vendor_no",response["vendNo"])
          end
          if response["partnerNo"].present?
            @customer_record.update_attribute("partner_no",response["partnerNo"]  )
          end
          @customer_record.update_attribute("accounts",response["acctSwitch"].join(","))
        end
        @redirect_to_first_url = assign_urls session[:menu_description]
        if @redirect_to_first_url == "javascript:void(0);"
          @sub_menu_url = assign_sub_menus session[:menu_description][0], session[:user_level]
          @redirect_to_first_url = @sub_menu_url["sub_menu"][0] if @sub_menu_url["sub_menu"].present?
        end
        redirect_to @redirect_to_first_url
      else
        if response["errCode"] == "4"
          if response["passwordLock"] == "N"
            flash.now[:alert] = I18n.t('expire_login', scope: 'user_session.create', expire_days: response['errMsg'].scan(/\d+/).first, default: response['errMsg'])
            render(:login,:locals=> {:errCode => "4", :pass_lock => "N"} )
          else
            flash.now[:alert] = I18n.t('expire_login', scope: 'user_session.create', expire_days: response['errMsg'].scan(/\d+/).first, default: response['errMsg'])
            render(:login,:locals=> {:errCode => "4", :pass_lock => response["passwordLock"]} )
          end
        else
          flash[:alert] = response["errMsg"]
          render :login
        end


      end
    else
      flash[:alert] = "Service temporarily unavailable"
      render :login
    end
  end

  # for switching user account for one to another it switch it without destroying session
  def switch_account
    cust_no = params[:customer_number].scan(/\d+/).first
    cust_name = params[:customer_number].split(cust_no).last.gsub(/[[:space:]]/, ' ').strip
    session[:customer_number] = cust_no
    session[:customer_Name] = cust_name
    # Populate New Customer into DB
    Kitting::Customer.find_by_user_name_and_user_level_and_cust_no(session[:user_name],session[:user_level],session[:customer_number]) || Kitting::Customer.create(:cust_no => session[:customer_number], :cust_name => session[:customer_Name], :user_name => session[:user_name],:user_level => session[:user_level],:user_type => session[:user_type])
    Kitting::CustomerConfigurations.find_or_create_by_cust_no(cust_no: cust_no,cust_name: cust_name,updated_by: current_customer )
    render :json => {:controller => params[:controller_name]}
  end

  # make user logged out
  def destroy
    reset_session
    redirect_to login_url
  end

  # notify user once he/she is not authorised
  def unauthorized
    reset_session
    flash[:alert] = "You are Not Authorized to View this Page. Your Session has expired !!!"
    render :login
  end

  # render layout on wrong password page or unauthorised page
  def login
    layout 'sign_in'
  end

end
