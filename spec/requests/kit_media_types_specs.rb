require 'spec_helper'
require 'requests_helper'
module Kitting
  describe KitMediaTypesController do
    before :each do
      @customer = FactoryGirl.create(:customer)
      login
    end
    include Rails.application.routes.url_helpers
    describe "Check KMT Creation Process" do
      it "adds a new KMT and displays the results" do
        get kit_media_types_path
        response.status.should eq(200)
        #expect{
        #  click_link 'New Kit Media-Type'
        #  fill_in 'Name', with: "Test Kit Media Type"
        #  fill_in 'Number of Compartments', with: 5
        #  fill_in 'Number of cups in Row1', with: 5
        #  click_button "Submit"
        #}.to change(KitMediaType, :count).by(1)
      end
    end
  end
end