require File.expand_path("../../test_helper", __FILE__)

class OpenOrdersControllerTest < ActionController::TestCase

  test "should not see pages without login" do
    get :index
    assert_redirected_to '/login'

    get :search
    assert_redirected_to '/login'

    get :invoice_display, :invoice_number => "2587"
    assert_redirected_to '/login'
  end

  test "should not see index without menu" do
    get :index
    assert_redirected_to '/unauthorized'
  end
  
  test "should get index" do
    session[:menu_description] = "Open Order Status"
    get :index
    assert_response :success
  end

  test "should get search" do
    session[:customer_number] = "029540"
    session[:user_name] = "BE.PHIL.BE"
    session[:user_level] = "5"
    session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
    get :search, :invoice_number => "HPXW30"
    assert_response :success
  end

  test "should not get invoice display with user level less than 4" do
    session[:customer_number] = "025424"
    session[:user_name] = "MACONBE"
    session[:user_level] = "4"
    session[:customer_Name] = "BOEING MACON"
    get :invoice_display, :invoice_number => "HPXW30"
    assert_redirected_to '/unauthorized'
  end

  test "should get invoice display with user level greater than 4" do
    session[:customer_number] = "029540"
    session[:user_name] = "BE.PHIL.BE"
    session[:user_level] = "5"
    session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
    get :invoice_display, :invoice_number => "HPXW30"
    assert_response :success
  end

end