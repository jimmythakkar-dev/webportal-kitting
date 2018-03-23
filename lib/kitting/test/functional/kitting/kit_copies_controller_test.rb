require 'test_helper'

module Kitting
  class KitCopiesControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
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
