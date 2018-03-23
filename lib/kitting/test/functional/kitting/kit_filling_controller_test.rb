require 'test_helper'

module Kitting
  class KitFillingControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get show" do
      get :show
      assert_response :success
    end

    test "should get create_filling_show" do
      get :create_filling_show
      assert_response :success
    end

    test "should get kit_filling_create" do
      get :kit_filling_create
      assert_response :success
    end

    test "should get edit" do
      get :edit
      assert_response :success
    end

    test "should get update" do
      get :update
      assert_response :success
    end

    test "should get kit_filling_edit" do
      get :kit_filling_edit
      assert_response :success
    end

    test "should get fill_all_cups" do
      get :fill_all_cups
      assert_response :success
    end

    test "should get destroy" do
      get :destroy
      assert_response :success
    end

    test "should get search_parts" do
      get :search_parts
      assert_response :success
    end

    test "should get edit_search_parts" do
      get :edit_search_parts
      assert_response :success
    end

    test "should get reset_filled_kit" do
      get :reset_filled_kit
      assert_response :success
    end

  end
end
