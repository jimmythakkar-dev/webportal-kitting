require 'test_helper'

module Kitting
  class KitReceivingControllerTest < ActionController::TestCase
    test "should not see pages without login" do
      get :index
      assert_redirected_to '/login'

      get :search
      assert_redirected_to '/login'

      get :create_filling_show
      assert_redirected_to '/login'

      get :edit
      assert_redirected_to '/login'

      post :kit_filling_edit
      assert_redirected_to '/login'

      post :pick_ticket_print
      assert_redirected_to '/login'

      get :fill_all_cups
      assert_redirected_to '/login'

      delete :destroy
      assert_redirected_to '/login'

      post :toggle_data
      assert_redirected_to '/login'
    end

    test "should not get index with user level less than 4" do
      session[:customer_number] = "029540"
      session[:user_name] = "BOEING.PHIL.FM"
      session[:user_level] = "3"
      session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
      get :index
      assert_redirected_to '/unauthorized'
    end

    test "should get index with user level greater than or equal to 4" do
      session[:customer_number] = "029540"
      session[:user_name] = "BE.PHIL.BE"
      session[:user_level] = "5"
      session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
      get :index
      assert_response :success
    end

    test "should get search" do
      session[:customer_number] = "029540"
      session[:user_name] = "BE.PHIL.BE"
      session[:user_level] = "5"
      session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
      get :search
      assert_response :success
    end

    test "should get pick_ticket" do
      get :pick_ticket
      assert_response :success
    end

    test "should get pick_ticket_print" do
      get :pick_ticket_print
      assert_response :success
    end

    test "should get show" do
      get :show
      assert_response :success
    end

    test "should get print_label" do
      get :print_label
      assert_response :success
    end

  end
end
