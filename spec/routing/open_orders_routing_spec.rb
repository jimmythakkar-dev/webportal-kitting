require "spec_helper"

describe OpenOrdersController do
  describe "routing" do

    it "routes to #index" do
      get("/open_orders").should route_to("open_orders#index")
    end

    it "routes to #invoice_display" do
      get("/open_orders/43/invoice_display").should route_to("open_orders#invoice_display")
    end

  end
end
