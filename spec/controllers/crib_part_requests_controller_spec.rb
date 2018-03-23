require 'rails_helper'

RSpec.describe CribPartRequestsController, :type => :controller do

  describe "GET index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET history" do
    it "returns http success" do
      get :history
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET report" do
    it "returns http success" do
      get :report
      expect(response).to have_http_status(:success)
    end
  end

end
