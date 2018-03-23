require_dependency "kitting/application_controller"

module Kitting
  class CustomersController < ApplicationController
    def index
      if can?(:>, "5")
        @customers = Kitting::Customer.where("id IN (?)", current_company)
      else
        redirect_to main_app.unauthorized_url
      end
    end

    def show
      @customer = Kitting::Customer.find_by_id(params[:id])
      upload_configuration = @customer.upload_configuration ? @customer.upload_configuration : Kitting::Customer.find_by_cust_no_and_cust_name("SYSTEM","SYSTEM").upload_configuration
      @column_hash = JSON.parse(upload_configuration)
    end

    def edit
      @customer = Kitting::Customer.find_by_id(params[:id])
      upload_configuration = @customer.upload_configuration ? @customer.upload_configuration : Kitting::Customer.find_by_cust_no_and_cust_name("SYSTEM","SYSTEM").upload_configuration
      @column_hash = JSON.parse(upload_configuration)
    end

    def update
      if current_customer
        required_params = ["utf8","_method","authenticity_token","commit","action","controller","id"]
        @customer = Kitting::Customer.find_by_id(current_customer)
        params.except!( *required_params )
        params.each{|k,v| v.squish! }
        if check_uniqueness(params.values)
          upload_configuration = params.to_json
          if @customer.update_attribute(:upload_configuration, upload_configuration)
            flash[:notice] = 'Successfully Updated'
            redirect_to(@customer)
          else
            render 'edit'
          end
        else
          flash.now[:alert] = "Spreadsheet column name should be unique"
          @column_hash = params
          render 'edit'
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end
    def use_default
      @customer = Kitting::Customer.find_by_id(current_customer)
      if @customer
        @customer.update_attribute(:upload_configuration, nil)
        flash[:notice] = 'Successfully Updated'
        redirect_to(@customer)
      end

    end

    private

    def check_uniqueness params
      if params.uniq.length == params.length
        true
      else
        false
      end
    end
  end
end
