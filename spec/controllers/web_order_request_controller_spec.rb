require 'spec_helper'

describe WebOrderRequestController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'process_form'" do
    it "returns http success" do
      get 'process_form'
      response.should be_success
    end
  end

end
