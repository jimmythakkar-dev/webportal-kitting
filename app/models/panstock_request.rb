class PanstockRequest
  def self.get_select_values
    select_tag_values =  [[I18n.translate("sort_by",:scope => "open_orders.index"), ""],
                          [I18n.translate("today",:scope => "open_orders.index"), "0"],
                          ["2 #{I18n.translate("days",:scope => "open_orders.index")}", "2"],
                          ["3 #{I18n.translate("days",:scope => "open_orders.index")}", "3"],
                          ["5 #{I18n.translate("days",:scope => "open_orders.index")}", "5"],
                          ["1 #{I18n.translate("week",:scope => "open_orders.index")}", "7"],
                          ["2 #{I18n.translate("weeks",:scope => "open_orders.index")}", "14"],
                          ["1 #{I18n.translate("month",:scope => "open_orders.index")}", "30"],
                          ["2 #{I18n.translate("months",:scope => "open_orders.index")}", "60"],
                          ["3 #{I18n.translate("months",:scope => "open_orders.index")}", "90"],
                          ["6 #{I18n.translate("months",:scope => "open_orders.index")}", "180"],
                          [I18n.translate("year",:scope => "open_orders.index"), "365"],
                          [I18n.translate("ALL",:scope => "critical_watch.index").humanize, "1000"]]
    select_tag_values
  end
end