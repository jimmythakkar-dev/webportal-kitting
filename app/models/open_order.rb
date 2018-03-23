class OpenOrder
  ##
    # Preparing select box values for date range
    # Including Today, 2 Days, 3 Days etc
    # Default to 2 Months
  ##
  def self.get_select_values
    select_tag_values = [[I18n.translate("today",:scope => "open_orders.index"),"0"], ["2 #{I18n.translate("days",:scope => "open_orders.index")}","2"], ["3 #{I18n.translate("days",:scope => "open_orders.index")}","3"],
                          ["5 #{I18n.translate("days",:scope => "open_orders.index")}","5"], ["1 #{I18n.translate("week",:scope => "open_orders.index")}","7"], ["2 #{I18n.translate("weeks",:scope => "open_orders.index")}","14"],
                          ["1 #{I18n.translate("month",:scope => "open_orders.index")}","30"], ["2 #{I18n.translate("months",:scope => "open_orders.index")}","60"], ["3 #{I18n.translate("months",:scope => "open_orders.index")}","90"],
                          ["4 #{I18n.translate("months",:scope => "open_orders.index")}","120"], ["5 #{I18n.translate("months",:scope => "open_orders.index")}","150"],
                          ["6 #{I18n.translate("months",:scope => "open_orders.index")}","180"], ["8 #{I18n.translate("months",:scope => "open_orders.index")}","240"], [I18n.translate("year",:scope => "open_orders.index"),"365"]]
    select_tag_values
  end

  ##
    # Preparing select box values for search by values
    # Including Part Number, PO Number, All Open Orders
  ##
  def self.get_search_values
    search_by_values = [[I18n.translate("part_number",:scope => "open_orders.index"),"pn"],[I18n.translate("po_number",:scope => "open_orders.index"),"po"],
                         [I18n.translate("all_open_order",:scope => "open_orders.index"),"all"]]

    search_by_values
  end
end
