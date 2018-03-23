module ReportsHelper
  def get_file_details(file)
    @file_first_part = File.basename(file).split(".").first
    @file_name = @file_first_part.split("_").last
    case @file_name
      when "BinMap"
        @report_name = "#{t("bin_map",:scope => "reports.index")}"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "BinMap".first(6).try(:downcase)
        @report_generate = @report_variable + "gen"
      when "onHandRpt"
        @report_name = "#{t("on_hand",:scope => "reports.index")}"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "onHandRpt".first(6).try(:downcase)
        @report_generate = @report_variable + "gen"
      when "ConsignInvRpt"
        @report_name = "#{t("consignment_inventory_report",:scope => "reports.index")}"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "ConsignInvRpt".first(6).try(:downcase)
        @report_generate = @report_variable + "gen"
      when "OpenOrdersRpt"
        @report_name = "#{t("open_orders",:scope => "reports.index")}"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "OpenOrdersRpt".first(6).try(:downcase)
        @report_generate = @report_variable + "gen"
      when "EmptiesRpt"
        @report_name = "#{t("empties",:scope => "reports.index")}"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "EmptiesRpt".first(6).try(:downcase)
        @report_generate = @report_variable + "gen"
      when "BinActivityRpt"
        @report_name = "Scanning data for selected periods - Bin Activity"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "BinActivityRpt".first(6).try(:downcase)
        @report_generate = @report_variable + "gen"
      when "CustForecastRpt"
        @report_name = "#{t("cust_forecast",:scope => "reports.index")}"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "CustForecastRpt".first(6).try(:downcase)
        @report_generate = @report_variable + "gen"
      when "PastDueRpt"
        @report_name = "#{t("past_due_report",:scope => "reports.index")}"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "PastDueRpt".first(6).try(:downcase)
        @report_generate = @report_variable + "gen"
      when "QCLabTracking"
        @report_name = "#{t("qc_lab_report",:scope => "reports.index")}"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "QCLabTracking".first(5).try(:downcase)
        @report_generate = @report_variable + "gen"
      when "DESK"
        @report_name = "#{t('agusta.weekly_extra_requests_report')}"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "DeskRequestRpt".first(14).try(:downcase)
        @report_generate = @report_variable + "gen"
      when "kit"
        @report_name = "#{t('agusta.weekly_kit_report')}"
        @report_date = File.new(file).mtime.strftime("%m/%d/%Y")
        @report_time = File.new(file).mtime.strftime("%l:%M %p")
        @report_variable = "WeeklyKitRpt".first(12).try(:downcase)
        @report_generate = @report_variable + "gen"
    end
  end
end
