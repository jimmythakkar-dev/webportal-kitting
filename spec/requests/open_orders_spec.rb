require 'spec_helper'

describe "OpenOrders" do
  describe "GET /open_orders" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get open_orders_path
      response.status.should eq(200)
    end
  end
end
