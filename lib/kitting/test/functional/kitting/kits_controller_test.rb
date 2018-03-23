require 'test_helper'

module Kitting
  class KitsControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get search" do
      get :search
      assert_response :success
    end

    test "should get kit_in_draft" do
      get :kit_in_draft
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should get create" do
      get :create
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

    test "should get show" do
      get :show
      assert_response :success
    end

    test "should get destroy" do
      get :destroy
      assert_response :success
    end

    test "should get detail_design" do
      get :detail_design
      assert_response :success
    end

    test "should get part_look_up" do
      get :part_look_up
      assert_response :success
    end

    test "should get kits_approval" do
      get :kits_approval
      assert_response :success
    end

    test "should get approved_kits" do
      get :approved_kits
      assert_response :success
    end

    test "should get add_queue" do
      get :add_queue
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

    test "should get print_label" do
      get :print_label
      assert_response :success
    end

    test "should get delete_record" do
      get :delete_record
      assert_response :success
    end

    test "should get detail_design_binder" do
      get :detail_design_binder
      assert_response :success
    end

    test "should get new_copy" do
      get :new_copy
      assert_response :success
    end

    test "should get create_copy" do
      get :create_copy
      assert_response :success
    end

    test "should get update_cardex" do
      get :update_cardex
      assert_response :success
    end

    test "should get kits_in_demand" do
      get :kits_in_demand
      assert_response :success
    end

  end
end
