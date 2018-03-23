require 'spec_helper'

module Kitting
  describe KitMediaTypesController do
    before :each do
      @customer = FactoryGirl.create(:customer)
      Kitting::KitMediaTypesController.stub(:get_acess_right).and_return(true)
      Kitting::KitMediaTypesController.stub(:conf_media_type).and_return(true)
    end

    describe "GET #index" do
      it "can access index" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = @customer.user_level
        session[:customer_Name] = @customer.cust_name
        get :index, use_route: :kitting
        response.should render_template(:index)
      end

      it "cannot access index" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = "3"
        session[:customer_Name] =  @customer.cust_name
        get :index, use_route: :kitting
        response.should_not render_template(:index)
      end

      it "populates an array of kit media types" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = @customer.user_level
        session[:customer_Name] = @customer.cust_name
        kit_media_type = FactoryGirl.create(:kit_media_type, customer_number: @customer.cust_no)
        get :index, use_route: :kitting
        assigns(:kit_media_types).should eq([kit_media_type])
      end

      it "renders the :index view" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = @customer.user_level
        session[:customer_Name] = @customer.cust_name
        get :index, use_route: :kitting
        response.should render_template(:index)
      end
    end

    describe "GET #show" do
      it "can access show" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = @customer.user_level
        session[:customer_Name] = @customer.cust_name
        get :show, id: FactoryGirl.create(:kit_media_type), use_route: :kitting
        response.should render_template(:show)
      end

      it "cannot access show" do
        session[:customer_number] = "025424"
        session[:user_name] = "MACONBE"
        session[:user_level] = "3"
        session[:customer_Name] = "BOEING MACON"
        response.should render_template(:file => "#{Rails.root}/UserSessionsController/login")
      end

      it "assigns the requested kit_media_type to @kit_media_type" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = @customer.user_level
        session[:customer_Name] = @customer.cust_name
        kit_media_type = FactoryGirl.create(:kit_media_type)
        get :show, id: kit_media_type, use_route: :kitting
        assigns(:kit_media_type).should eq(kit_media_type)
      end

      it "renders the #show view" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = @customer.user_level
        session[:customer_Name] = @customer.cust_name
        get :show, id: FactoryGirl.create(:kit_media_type), use_route: :kitting
        response.should render_template :show
      end
    end

    describe "GET #new" do
      it "can access new" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = @customer.user_level
        session[:customer_Name] = @customer.cust_name
        get :new, use_route: :kitting
        response.should render_template(:new)
      end

      it "cannot access new" do
        session[:customer_number] = "025424"
        session[:user_name] = "MACONBE"
        session[:user_level] = "3"
        session[:customer_Name] = "BOEING MACON"
        response.should render_template(:file => "#{Rails.root}/UserSessionsController/login")
      end

      it "assigns a new kit_media_type as @kit_media_type" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = @customer.user_level
        session[:customer_Name] = @customer.cust_name
        get :new, use_route: :kitting
        assigns(:kit_media_type).should be_a_new(KitMediaType)
      end
    end

    describe "GET #edit" do
      it "can access edit" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = @customer.user_level
        session[:customer_Name] = @customer.cust_name
        get :edit, id: FactoryGirl.create(:kit_media_type), use_route: :kitting
        response.should render_template(:edit)
      end

      it "cannot access edit" do
        session[:customer_number] = "025424"
        session[:user_name] = "MACONBE"
        session[:user_level] = "3"
        session[:customer_Name] = "BOEING MACON"
        response.should render_template(:file => "#{Rails.root}/UserSessionsController/login")
      end

      it "assigns the requested kit_media_type as @kit_media_type" do
        session[:customer_number] = @customer.cust_no
        session[:user_name] = @customer.user_name
        session[:user_level] = @customer.user_level
        session[:customer_Name] = @customer.cust_name
        kit_media_type = FactoryGirl.create(:kit_media_type)
        get :edit, id: kit_media_type, use_route: :kitting
        assigns(:kit_media_type).should eq(kit_media_type)
      end
    end

    describe "POST create" do
      context "with valid params" do
        it "creates a new kit media type" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          expect {
            post :create, kit_media_type: FactoryGirl.attributes_for(:kit_media_type), use_route: :kitting
          }.to change(KitMediaType, :count).by(1)
        end

        it "assigns a newly created kit_media_type as @kit_media_type" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          post :create, {:kit_media_type => FactoryGirl.attributes_for(:kit_media_type), use_route: :kitting}
          assigns(:kit_media_type).should be_a(KitMediaType)
          assigns(:kit_media_type).should be_persisted
        end

        it "redirects to the new kit_media_type" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          post :create, kit_media_type: FactoryGirl.attributes_for(:kit_media_type), use_route: :kitting
          response.should redirect_to(KitMediaType.last)
        end
      end
      context "with invalid params" do
        it "Does not save a new kit media type" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          expect {
            post :create, kit_media_type: FactoryGirl.attributes_for(:invalid_kit_media_type), use_route: :kitting
          }.to_not change(KitMediaType, :count).by(1)
        end


        it "re-renders to the new method" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          post :create, kit_media_type: FactoryGirl.attributes_for(:invalid_kit_media_type), use_route: :kitting
          response.should render_template :new
        end
      end
    end

    describe 'PUT update' do
      before :each do
        @kit_media_type = FactoryGirl.create(:kit_media_type, name: "New Media Type", kit_type: "Non-Configurable")
      end
      context "valid attributes" do
        it "located the requested @kit_media_type" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          put :update, id: @kit_media_type, kit_media_type: FactoryGirl.attributes_for(:kit_media_type),use_route: :kitting
          assigns(:kit_media_type).should eq(@kit_media_type)
        end
        it "changes @KMT's attributes" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          put :update, id: @kit_media_type,
              kit_media_type: FactoryGirl.attributes_for(:kit_media_type, name: "Old KMT", kit_type: "Non-Configurable"),
              use_route: :kitting
          @kit_media_type.reload
          @kit_media_type.name.should eq("Old KMT")
          @kit_media_type.kit_type.should eq("Non-Configurable")
        end
        it "redirects to the updated kit media type" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          put :update, id: @kit_media_type,
              kit_media_type: FactoryGirl.attributes_for(:kit_media_type),use_route: :kitting
          response.should redirect_to @kit_media_type
        end
      end
      context "invalid attributes" do
        it "locates the requested @kit_media_type" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          put :update, id: @kit_media_type, kit_media_type: FactoryGirl.attributes_for(:invalid_kit_media_type),use_route: :kitting
          assigns(:kit_media_type).should eq(@kit_media_type)
        end
        it "changes @KMT's attributes" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          put :update, id: @kit_media_type,
              kit_media_type: FactoryGirl.attributes_for(:kit_media_type, name: nil, kit_type: "Non-Configurable"),
              use_route: :kitting
          @kit_media_type.reload
          @kit_media_type.name.should_not eq(nil)
          @kit_media_type.kit_type.should eq("Non-Configurable")
        end
        it "re-renders the edit method" do
          session[:customer_number] = @customer.cust_no
          session[:user_name] = @customer.user_name
          session[:user_level] = @customer.user_level
          session[:customer_Name] = @customer.cust_name
          put :update, id: @kit_media_type,
              kit_media_type: FactoryGirl.attributes_for(:kit_media_type, name: nil),
              use_route: :kitting
          response.should render_template :edit
        end
      end
    end
  end
end