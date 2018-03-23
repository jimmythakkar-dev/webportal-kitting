require File.expand_path("../../test_helper", __FILE__)

class PartsControllerTest < ActionController::TestCase

  test "should get new" do
    @controller = Kitting::PartsController.new
    session[:customer_number] = "029540"
    session[:user_name] = "BE.PHIL.BE"
    session[:user_level] = "5"
    session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
    get "new", {:use_route => :kitting, :xid => ["NAS1329S3K180"],:custNo => session[:customer_number] }
    assert_response :success
  end

  test "should get create part" do
    @controller = Kitting::PartsController.new
    session[:customer_number] = "029540"
    session[:user_name] = "BE.PHIL.BE"
    session[:user_level] = "5"
    session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
    assert_difference('Kitting::Part.count') do
     post "create",{:use_route => :kitting, :part => {:description => "test_description" , :image_name => "test_image.jpg", :part_number => "NAS1291C8", :name => "test_name"}}
    end
    assert_redirected_to part_path(assigns(:part))
    assert_equal 'Part was successfully created.', flash[:notice]
  end



  test "should get index" do
    @controller = Kitting::PartsController.new
    session[:customer_number] = "029540"
    session[:user_name] = "BE.PHIL.BE"
    session[:user_level] = "5"
    session[:customer_Name] = "BOEING PHILADELPHIA 4PL"
    get "index", {:use_route => :kitting, :custNo => session[:customer_number], :partNo => "NAS", :custNo => session[:customer_number], :kitStatuses => "1,2,6"}
    assert_response :success
  end





end