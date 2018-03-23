require 'test_helper'

module Kitting
  class CupPartsControllerTest < ActionController::TestCase
    test "should get create" do
      get :create
      assert_response :success
    end

    test "should get update_quantity" do
      get :update_quantity
      assert_response :success
    end

  end
end
