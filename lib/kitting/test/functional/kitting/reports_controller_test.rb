require 'test_helper'

module Kitting
  class ReportsControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get kit_filling_tracking_history" do
      get :kit_filling_tracking_history
      assert_response :success
    end

    test "should get sos_pn_sortage" do
      get :sos_pn_sortage
      assert_response :success
    end

  end
end
