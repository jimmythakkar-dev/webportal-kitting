require 'test_helper'

module Kitting
  class KitHistoryControllerTest < ActionController::TestCase
    test "should get show" do
      get :show
      assert_response :success
    end

  end
end
