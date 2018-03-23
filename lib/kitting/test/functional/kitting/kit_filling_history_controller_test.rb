require 'test_helper'

module Kitting
  class KitFillingHistoryControllerTest < ActionController::TestCase
    test "should get show" do
      get :show
      assert_response :success
    end

  end
end
