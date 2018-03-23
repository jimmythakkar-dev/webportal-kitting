require 'test_helper'

module Kitting
  class VersionsControllerTest < ActionController::TestCase
    test "should get revert" do
      get :revert
      assert_response :success
    end

  end
end
