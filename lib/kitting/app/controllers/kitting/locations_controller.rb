require_dependency "kitting/application_controller"

module Kitting
  class LocationsController < ApplicationController
    before_filter :get_acess_right
    # GET /locations
    # GET /locations.json

    # GET lists all locations available for the current customer
    def index
      if can?(:>=, "5")
        @locations = Kitting::Location.where("customer_number = ? OR customer_number IS NULL",session[:customer_number])
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @locations }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    # GET /locations/1
    # GET /locations/1.json Dispalys particular Location details
    def show
      if can?(:>=, "5")
        @location = Kitting::Location.find(params[:id])
        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @location }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    # GET /locations/new
    # GET /locations/new.json Creates New Json to be avilable for entering data
    def new
      if can?(:>=, "5")
        @location = Kitting::Location.new
        respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @location }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    # GET /locations/1/edit Edits Location details
    def edit
      if can?(:>=, "5")
        @location = Kitting::Location.find(params[:id])
      else
        redirect_to main_app.unauthorized_url
      end
    end

    # POST /locations
    # POST /locations.json Creates a New Location
    def create
      if can?(:>=, "5")
        @location = Kitting::Location.new(params[:location])
        @location.customer_number = session[:customer_number]
        respond_to do |format|
          if @location.save
            format.html { redirect_to @location, notice: 'Location is created successfully.' }
            format.json { render json: @location, status: :created, location: @location }
          else
            format.html { render action: "new" }
            format.json { render json: @location.errors, status: :unprocessable_entity }
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    # PUT /locations/1
    # Updating locations customer specific
    def update
      if can?(:>=, "5")
        @location = Kitting::Location.find(params[:id])
        @location_attributes = params[:location].merge(:customer_number => session[:customer_number])
        respond_to do |format|
          if @location.update_attributes(@location_attributes)
            format.html { redirect_to @location, notice: 'Location is updated successfully.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @location.errors, status: :unprocessable_entity }
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

  end
end