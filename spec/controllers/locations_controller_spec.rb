require 'spec_helper'

module Kitting
  describe LocationsController do
    before(:each) do
      FactoryGirl.create(:customer)
      Kitting::LocationsController.stub(:get_acess_right).and_return(true)
    end
    describe "GET #index" do
    
      it "can access index" do
        session[:customer_number] = "029540"
        session[:user_name] = "BE.PHIL.BE"
        session[:user_level] = "5"
        session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
        get :index, use_route: :kitting
        response.should render_template(:index)
      end

      it "cannot access index" do
        session[:customer_number] = "025424"
        session[:user_name] = "MACONBE"
        session[:user_level] = "3"
        session[:customer_Name] = "BOEING MACON"
#        get :login, use_route: :root
        response.should render_template(:file => "#{Rails.root}/UserSessionsController/login")
#        response.should redirect_to(login_path)
      end

      it "populates an array of locations" do
        session[:customer_number] = "029540"
        session[:user_name] = "BE.PHIL.BE"
        session[:user_level] = "5"
        session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
        location = FactoryGirl.create(:location)
        get :index, use_route: :kitting
        assigns(:locations).should eq([location])
      end

      it "renders the :index view" do
        session[:customer_number] = "029540"
        session[:user_name] = "BE.PHIL.BE"
        session[:user_level] = "5"
        session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
        get :index, use_route: :kitting
        response.should render_template(:index)
      end
    end

    describe "GET #show" do
      
      it "can access show" do
        session[:customer_number] = "029540"
        session[:user_name] = "BE.PHIL.BE"
        session[:user_level] = "5"
        session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
        get :show, id: FactoryGirl.create(:location), use_route: :kitting
        response.should render_template(:show)
      end

      it "cannot access show" do
        session[:customer_number] = "025424"
        session[:user_name] = "MACONBE"
        session[:user_level] = "3"
        session[:customer_Name] = "BOEING MACON"
#        get :login, use_route: :root
        response.should render_template(:file => "#{Rails.root}/UserSessionsController/login")
#        response.should redirect_to(login_path)
      end
      
      it "assigns the requested location to @location" do
        session[:customer_number] = "029540"
        session[:user_name] = "BE.PHIL.BE"
        session[:user_level] = "5"
        session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
        location = FactoryGirl.create(:location)
        get :show, id: location, use_route: :kitting
        assigns(:location).should eq(location)
      end

      it "renders the #show view" do
        session[:customer_number] = "029540"
        session[:user_name] = "BE.PHIL.BE"
        session[:user_level] = "5"
        session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
        get :show, id: FactoryGirl.create(:location), use_route: :kitting
        response.should render_template :show
      end
      
    end

    describe "GET #new" do

      it "can access new" do
        session[:customer_number] = "029540"
        session[:user_name] = "BE.PHIL.BE"
        session[:user_level] = "5"
        session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
        get :new, use_route: :kitting
        response.should render_template(:new)
      end

      it "cannot access new" do
        session[:customer_number] = "025424"
        session[:user_name] = "MACONBE"
        session[:user_level] = "3"
        session[:customer_Name] = "BOEING MACON"
#        get :login, use_route: :root
        response.should render_template(:file => "#{Rails.root}/UserSessionsController/login")
#        response.should redirect_to(login_path)
      end

      it "assigns a new location as @location" do
        session[:customer_number] = "029540"
        session[:user_name] = "BE.PHIL.BE"
        session[:user_level] = "5"
        session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
        get :new, use_route: :kitting
        assigns(:location).should be_a_new(Location)
      end
    end

    describe "GET #edit" do

      it "can access edit" do
        session[:customer_number] = "029540"
        session[:user_name] = "BE.PHIL.BE"
        session[:user_level] = "5"
        session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
        get :edit, id: FactoryGirl.create(:location), use_route: :kitting
        response.should render_template(:edit)
      end

      it "cannot access edit" do
        session[:customer_number] = "025424"
        session[:user_name] = "MACONBE"
        session[:user_level] = "3"
        session[:customer_Name] = "BOEING MACON"
#        get :login, use_route: :root
        response.should render_template(:file => "#{Rails.root}/UserSessionsController/login")
#        response.should redirect_to(login_path)
      end
      
      it "assigns the requested location as @location" do
        session[:customer_number] = "029540"
        session[:user_name] = "BE.PHIL.BE"
        session[:user_level] = "5"
        session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
        location = FactoryGirl.create(:location)
        get :edit, id: location, use_route: :kitting
        assigns(:location).should eq(location)
      end
    end

    describe "POST create" do
      describe "with valid params" do

        it "creates a new location" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          expect {
            post :create, location: FactoryGirl.attributes_for(:location), use_route: :kitting
            }.to change(Location, :count).by(1)
        end

        it "assigns a newly created location as @location" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          post :create, {:location => FactoryGirl.attributes_for(:location), use_route: :kitting}
          assigns(:location).should be_a(Location)
          assigns(:location).should be_persisted
        end

        it "redirects to the new location" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          post :create, location: FactoryGirl.attributes_for(:location), use_route: :kitting
          response.should redirect_to(Location.last)
        end
        
      end

      describe "with invalid attributes" do
        it "does not save the new contact" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          expect{
            post :create, location: FactoryGirl.attributes_for(:invalid_location), use_route: :kitting
          }.to_not change(Location,:count)
        end

        it "re-renders the new method" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          post :create, location: FactoryGirl.attributes_for(:invalid_location), use_route: :kitting
          response.should render_template :new
        end
      end
    end

#    describe 'PUT update' do
#      describe "valid attributes" do
#        it "updates the requested product" do
#          session[:customer_number] = "029540"
#          session[:user_name] = "BE.PHIL.BE"
#          session[:user_level] = "5"
#          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
#          Location.any_instance.should_receive(:update_attributes).with({ "name" => "MyString" })
#          put :update, {:id => FactoryGirl.create(:location), :location => { "name" => "MyString" }, use_route: :kitting}
#        end
#
#        it "assigns the requested location as @location" do
#          session[:customer_number] = "029540"
#          session[:user_name] = "BE.PHIL.BE"
#          session[:user_level] = "5"
#          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
#          location = FactoryGirl.create(:location)
#          put :update, {:id => location, :location => { "name" => "MyString" }, use_route: :kitting}
#          assigns(:location).should eq(location)
#        end
#
#        it "redirects to the location" do
#          session[:customer_number] = "029540"
#          session[:user_name] = "BE.PHIL.BE"
#          session[:user_level] = "5"
#          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
#          location = FactoryGirl.create(:location)
#          put :update, {:id => location, :location => { "name" => "MyString"}, use_route: :kitting}
#          response.should redirect_to(location)
#        end
#
#      end
#
#      describe "invalid attributes" do
#        it "assigns the location as @location" do
#          session[:customer_number] = "029540"
#          session[:user_name] = "BE.PHIL.BE"
#          session[:user_level] = "5"
#          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
#          product = Product.create! valid_attributes
#        # Trigger the behavior that occurs when invalid params are submitted
#          Loc.any_instance.stub(:save).and_return(false)
#          put :update, {:id => product.to_param, :product => { "name" => "invalid value" }}, valid_session
#          assigns(:product).should eq(product)
#        end
#      end
#    end

    describe 'PUT update' do
      before :each do
        @location = FactoryGirl.create(:location, name: "MyLocation")
      end
      describe "valid attributes" do
        it "located the requested @location" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          put :update, id: @location, contact: FactoryGirl.attributes_for(:location), use_route: :kitting
          assigns(:location).should eq(@location)
        end

        it "changes @location's attributes" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          put :update, id: @location,
            location: FactoryGirl.attributes_for(:location, name: "Location"), use_route: :kitting
          @location.reload
          @location.name.should eq("Location")
        end

        it "redirects to the updated location" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          put :update, id: @location, location: FactoryGirl.attributes_for(:location), use_route: :kitting
          response.should redirect_to @location
        end

      end

      describe "invalid attributes" do
        it "locates the requested @location" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          put :update, id: @location, location: FactoryGirl.attributes_for(:invalid_location), use_route: :kitting
          assigns(:location).should eq(@location)
        end

        it "does not change @location's attributes" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          put :update, id: @location,
            location: FactoryGirl.attributes_for(:location, name: nil), use_route: :kitting
          @location.reload
          @location.name.should eq("MyLocation")
        end

        it "re-renders the edit method" do
          session[:customer_number] = "029540"
          session[:user_name] = "BE.PHIL.BE"
          session[:user_level] = "5"
          session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
          put :update, id: @location, location: FactoryGirl.attributes_for(:invalid_location), use_route: :kitting
          response.should render_template :edit
        end
      end
    end

  end
end
