require File.expand_path("../../test_helper", __FILE__)

class RmaControllerTest < ActionController::TestCase
    
  test "should not see pages without login" do
    get :show
    assert_redirected_to '/login'

    get :search_invoice
    assert_redirected_to '/login'

    get :invoice_details, :invoice_num => "1234"
    assert_redirected_to '/login'

    post :submit
    assert_redirected_to '/login'
  end

  test "should get show with user level 5" do
    session[:customer_number] = "029540"
    session[:user_name] = "BE.PHIL.BE"
    session[:user_level] = "5"
    session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
    
    get :show
    assert_response :success
  end

  test "should not get show with user level less than 5" do
    session[:customer_number] = "025424"
    session[:user_name] = "MACONBE"
    session[:user_level] = "4"
    session[:customer_Name] = "BOEING MACON"
    get :show
    assert_redirected_to '/unauthorized'
  end

  test "should get search invoice" do
    session[:customer_number] = "029540"
    session[:user_name] = "BE.PHIL.BE"
    session[:user_level] = "5"
    session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
    get :search_invoice, :format => :js, :begin_date => "12/03/13", :end_date => "12/05/13", :invoice_number => "", :po_number => "", :part_number => "", :qty => ""
    assert_response :success
  end

  test "should get invoice details" do
    session[:customer_number] = "029540"
    session[:user_name] = "BE.PHIL.BE"
    session[:user_level] = "5"
    session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
    get :invoice_details, :invoice_num => "HR1TBN"
    assert_response :success
  end

  test "should post submit" do
    session[:customer_number] = "029540"
    session[:user_name] = "BE.PHIL.BE"
    session[:user_level] = "5"
    session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
    post :submit, :invoice_num => "HR39ZJ", :year => "2013", :name => "test",
      :reason_code => "R02", :email => "abc@gmail.com", :reason => "test_desc", "phone" => "",
      :fax => "", :qty14 => "4", :part_nos => "[\"MS27039C4-11\"]"
    assert_redirected_to "/rma"
  end
end
