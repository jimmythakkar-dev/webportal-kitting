require 'test_helper'

module Kitting
  class CupsControllerTest < ActionController::TestCase
    test "should get build" do
      get :build
      assert_response :success
    end

  end
end
