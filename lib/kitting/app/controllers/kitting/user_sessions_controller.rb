require_dependency "kitting/application_controller"

module Kitting
  class UserSessionsController < ApplicationController
#    skip_before_filter :authenticate
#
#    layout = 'sign_in'
#
#    def new
#      render layout: false
#    end
#
#    def create
#      response = invoke_webservice method: 'post',
#                                      action: 'userLogin', data: { userName: params[:username],
#                                                                password: params[:password] }
#      if response
#        if response["errCode"] == "0"
#          if response["userType"] == "C" || response["userType"] == "E" || response["userType"] == "V" || response["userType"] == "P"
#            session[:full_name] = response["fullName"]
#            session[:user_level] = response["userLevel"]
#            session[:buyer_email] = response["buyerEmail"]
#            session[:order_flag] = response["orderFlag"]
#            session[:user_name] = response["userName"]
#
#            #Ecom Menu
#            session[:menu_description] = response["menuDesc"]
#
#            #CUSTOMER
#
#            session[:customer_number] = response["custNo"]
#            session[:customer_Name] = response["custName"]
#            session[:contact] = response["contact"]
#            session[:phone_number] = response["phoneNo"]
#
#
#            #SLSMAN
#            session[:slsm_email] = response["slsmEmail"]
#            session[:slsm_name] = response["slsmName"]
#            session[:slsm_phone] = response["slsmPhone"]
#            session[:slsm_fax]  = response["slsmFax"]
#
#
#            #F.ACC.TYPE FILE VARS
#            session[:customer_type] = response["custType"]
#            # Populate New Customer into DB
#            Customer.find_by_user_name(response["fullName"]) || Customer.create(:cust_no => session[:customer_number], :cust_name => session[:customer_Name], :user_name => response["fullName"])
#          end
#          redirect_to kits_path
#        else
#          flash[:alert] = response["errMsg"]
#          render :login
#        end
#      else
#        flash[:error] = "Service temporarily unavailable"
#      end
#    end
#
#    def destroy
#      reset_session
#      redirect_to login_url
#    end
#
#    def login
#      layout 'sign_in'
#    end
  end
end