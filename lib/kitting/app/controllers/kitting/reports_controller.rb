require_dependency "kitting/application_controller"

module Kitting
  class ReportsController < ApplicationController
    before_filter :get_acess_right, :except => [:index,:kit_filling_tracking_history,:sos_pn_sortage,:order_fulfillment_tracking,:turn_count,:newly_designed_kits, :kit_fill_metrics, :view_charts, :sos_kits_in_process, :returned_parts_details, :kit_status,:delivery]
    before_filter :add_headers, :only=>[ :kit_filling_tracking_history,:sos_pn_sortage,:order_fulfillment_tracking,:turn_count,:newly_designed_kits, :kit_fill_metrics, :view_charts, :sos_kits_in_process, :returned_parts_details, :kit_status,:delivery]
    protect_from_forgery
    include KitsHelper
    layout "kitting/fit_to_compartment", :only => [:view_charts]
    ##
    # This action is of index page of reports Listing all the reports as per user access.
    ##
    def index
      if can?(:>=, "2")
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action fetches all the records from KitFillingHistoryReport Table in the selected date and writes the data to csv
    ##
    def kit_filling_tracking_history
      require "csv"
      if can?(:>=, "2")
        if ((params["begin_date"]) == "") || ((params["end_date"] == ""))
          @kit_filling = Kitting::KitFillingHistoryReport.where(:customer_number => current_customer.cust_no)
        else
          @kit_filling = Kitting::KitFillingHistoryReport.where(:customer_number => current_customer.cust_no,:filling_date => (Date.strptime(params["begin_date"].to_s, "%m%d%Y").midnight)..Date.strptime(params["end_date"].to_s, "%m%d%Y").midnight + 1.day)
        end
        File.open(Rails.public_path+"/excel/Kit-Filling Tracking History Report.csv", "w") do |csv|
          csv << "Kit Copy No/Work Order,Compartment No,Part,Demand Qty,Filled Qty,Created By,Time,Date\n"
          @kit_filling.each do |kit_filling|
            if kit_filling.demand_qty == "WL" && kit_filling.filled_qty == "0"
              kit_filling.filled_qty = "E"
            end
            if kit_filling.kit_copy_number.blank?
              column_value = kit_filling.kit_filling.kit_work_order.work_order.order_number rescue ""
            else
              column_value = kit_filling.kit_copy_number rescue ""
            end
            csv << "#{column_value},#{kit_filling.cup_no},#{kit_filling.part_number},"+
                "#{kit_filling.demand_qty},#{kit_filling.filled_qty},#{kit_filling.created_by},"+
                "#{kit_filling.filling_date.strftime("%I:%M%p")},#{kit_filling.filling_date.to_date}\n"
          end
        end
        send_file(Rails.public_path+"/excel/Kit-Filling Tracking History Report.csv",:disposition => "attachment")
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action fetches all the records from KitFilling Table in the selected date and writes the data to excel
    # after evaluating parts which in short quantity.
    ##
    def sos_pn_sortage
      if can?(:>=, "2")
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = "attachment; filename=SOS Kit Shipped Report.xls"
        headers['Cache-Control'] = ''

        # code to create xls file
        require 'writeexcel'
        workbook = WriteExcel.new(Rails.public_path+"/excel/SOS Kit Shipped Report.xls")
        worksheet  = workbook.add_worksheet("kit_filling")

        format = workbook.add_format
        partial_format = workbook.add_format
        empty_format = workbook.add_format
        align_right = workbook.add_format
        border = workbook.add_format

        format.set_bold
        empty_format.set_bg_color('red')
        empty_format.set_color('white')
        partial_format.set_bg_color('yellow')
        border.set_bottom(1)

        @row_value = 0
        @col_value = 0
        # create a table in xls file
        worksheet.set_column(0, 0, 20)
        worksheet.set_column(0, 1, 20)
        worksheet.set_column(0, 2, 20)
        worksheet.set_column(0, 3, 20)
        worksheet.set_column(0, 4, 20)
        worksheet.set_column(0, 5, 20)
        worksheet.set_column(0, 6, 20)
        worksheet.set_column(0, 7, 20)
        worksheet.set_column(0, 8, 20)

        worksheet.write(@row_value, 0,"SOS Kit Shipped Report",format)
        @row_value = @row_value+2
        worksheet.write(@row_value, 0,"Kit Filling Id", format)
        worksheet.write(@row_value, 1,"Kit Copy No/Work Order", format)
        worksheet.write(@row_value, 2,"Part", format)
        worksheet.write(@row_value, 3,"Demand Qty",format)
        worksheet.write(@row_value, 4,"Filled Qty",format)
        worksheet.write(@row_value, 5,"SOS Part Quantity",format)
        worksheet.write(@row_value, 6,"Created By",format)
        worksheet.write(@row_value, 7,"Time",format)
        worksheet.write(@row_value, 8,"Date",format)
        if ((params["sos_begin_date"]) != "") and ((params["sos_end_date"] != ""))
          @kit_order_fulfillment = Kitting::KitOrderFulfillment.find(:all,:conditions=>["filled_state in (0,2) and cust_no = ? and (created_at BETWEEN ? AND ?)",current_customer.cust_no, Date.strptime(params["sos_begin_date"].to_s, "%m%d%Y").midnight,Date.strptime(params["sos_end_date"].to_s, "%m%d%Y").midnight + 1.day],:order=>"created_at asc")
        end
        unless @kit_order_fulfillment.blank?
          @kit_filling_id = []
          @kit_filling = []
          @kit_filling_id << @kit_order_fulfillment.map(&:kit_filling_id)
          @kit_filling_id= @kit_filling_id.flatten
          @kit_filling_id.in_groups_of(900) do |filling_group|
            @kit_filling << Kitting::KitFilling.find(:all,:conditions=>["kit_fillings.id IN (?) and kit_filling_details.filled_state in ('E','P')",filling_group],:include =>[:kit_copy,:customer,{:kit_filling_details=>{:cup_part=>:part}}])
          end
          @kit_filling = @kit_filling.flatten if @kit_filling.present?

          @kit_filling.each do |kit_filling|
            if kit_filling.kit_copy.present?
              common_col = kit_filling.kit_copy.kit_version_number rescue ""
            else
              common_col = kit_filling.kit_work_order.work_order.order_number rescue ""
            end
            kit_filling.kit_filling_details.each do |kit_filling_details|
              @row_value = @row_value + 1
              unless kit_filling_details.try(:cup_part).blank?
                worksheet.write(@row_value,0,kit_filling.id)
                worksheet.write(@row_value,1,common_col)
                worksheet.write(@row_value,2,kit_filling_details.try(:cup_part).try(:part).try(:part_number))
                demand_qty = kit_filling_details.try(:cup_part).try(:demand_quantity)
                filled_qty = kit_filling_details.filled_quantity
              else
                worksheet.write(@row_value,2,"-")
              end
              demand_qty.present? ? worksheet.write(@row_value,3,demand_qty) : worksheet.write(@row_value,3,"0")
              demand_qty = (demand_qty == "Water-Level"  || demand_qty == "WL") ? demand_qty : demand_qty = demand_qty.to_i
              if kit_filling_details.try(:filled_quantity) == "WL" || kit_filling_details.try(:filled_quantity)== "S" || kit_filling_details.try(:filled_quantity)== "E"
                filled_qty = kit_filling_details.try(:filled_quantity)
              elsif kit_filling_details.try(:filled_quantity).blank? || kit_filling_details.try(:filled_quantity).to_i== 0
                filled_qty = (demand_qty == "Water-Level"  || demand_qty == "WL")? "E": kit_filling_details.try(:filled_quantity).to_i
              else
                filled_qty = kit_filling_details.try(:filled_quantity).to_i
              end
              worksheet.write(@row_value,4,filled_qty)
              if filled_qty == "S"
                worksheet.write(@row_value,5,demand_qty,partial_format)
              elsif filled_qty == "E"
                worksheet.write(@row_value,5,'WL',empty_format)
              elsif filled_qty == 0 || filled_qty.to_i > 0
                (filled_qty == 0)? worksheet.write(@row_value,5,demand_qty.to_i  - filled_qty.to_i ,empty_format) : worksheet.write(@row_value,5,demand_qty.to_i  - filled_qty.to_i ,partial_format)
              end
              worksheet.write(@row_value, 6,kit_filling.customer.user_name)
              worksheet.write(@row_value, 7,kit_filling.created_at.strftime("%I:%M%p"))
              worksheet.write(@row_value, 8,kit_filling.created_at.to_date)
            end
          end
          worksheet.write(@row_value, border)
        end
        workbook.close
        send_file Rails.public_path+"/excel/SOS Kit Shipped Report.xls",
                  :disposition => "attachment"
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action fetches all the records from KitOrderFulfillment Table in the selected date and writes the data to excel
    ##
    def order_fulfillment_tracking
      if can?(:>=, "2")
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = "attachment; filename=Order Fulfillment Tracking Report.xls"
        headers['Cache-Control'] = ''

        # code to create xls file
        require 'writeexcel'
        workbook = WriteExcel.new(Rails.public_path+"/excel/Order Fulfillment Tracking Report.xls")
        worksheet  = workbook.add_worksheet("kit_filling")

        format = workbook.add_format
        partial_format = workbook.add_format
        empty_format = workbook.add_format
        border = workbook.add_format
        header = workbook.add_format

        format.set_bold
        empty_format.set_bg_color('red')
        empty_format.set_color('white')
        partial_format.set_bg_color('yellow')
        border.set_bottom(1)
        header.set_bold
        header.set_header('Big')


        @row_value = 0
        @col_value = 0
        # create a table in xls file

        worksheet.set_column(0, 0, 20)
        worksheet.set_column(0, 1, 20)
        worksheet.set_column(0, 2, 20)
        worksheet.set_column(0, 3, 20)
        worksheet.set_column(0, 4, 20)
        worksheet.set_column(0, 5, 20)
        worksheet.set_column(0, 6, 20)
        worksheet.set_column(0, 7, 20)
        worksheet.set_column(0, 8, 20)
        worksheet.set_column(0, 9, 20)
        worksheet.set_column(0, 10, 20)

        worksheet.write(@row_value, 0,"Order Fulfillment Tracking Report",format)
        @row_value = @row_value+2
        worksheet.write(@row_value, 0,"Kit Filling Id:",format)
        worksheet.write(@row_value, 1,"Kit Copy No/Work Order:",format)
        worksheet.write(@row_value, 2,"Kit Number:",format)
        worksheet.write(@row_value, 3,"User Name", format)
        worksheet.write(@row_value, 4,"Customer Name",format)
        worksheet.write(@row_value, 5,"Filled State",format)
        worksheet.write(@row_value, 6,"Location Name",format)
        worksheet.write(@row_value, 7,"Order Number Closed",format)
        worksheet.write(@row_value, 8,"Scancode Closed",format)
        worksheet.write(@row_value, 9,"Time",format)
        worksheet.write(@row_value, 10,"Date",format)

        # loop for bin center parts data to show in table
        if ((params["begin_date2"]) == "") || ((params["end_date2"] == ""))
          @kit_filling = Kitting::KitOrderFulfillment.where(:cust_no => current_customer.cust_no)
        else
          @kit_filling = Kitting::KitOrderFulfillment.where(:cust_no => current_customer.cust_no,:created_at => (Date.strptime(params["begin_date2"].to_s, "%m%d%Y").midnight)..Date.strptime(params["end_date2"].to_s, "%m%d%Y").midnight + 1.day).includes(:customer).order('created_at asc')
        end

        @kit_filling.each_with_index do |kit_filling|
          if kit_filling.blank?
            "Not Available"
          else
            if kit_filling.kit_copy_number.blank?
              column_value = kit_filling.kit_filling.kit_work_order.work_order.order_number rescue ""
            else
              column_value = kit_filling.kit_copy_number rescue ""
            end
            @row_value = @row_value + 1
            worksheet.write(@row_value,0,kit_filling.kit_filling_id)
            worksheet.write(@row_value,1,column_value)
            worksheet.write(@row_value,2,kit_filling.kit_number)
            worksheet.write(@row_value,3,kit_filling.user_name)
            worksheet.write(@row_value,4,kit_filling.cust_name)
            if !kit_filling.filled_state.nil?
              if kit_filling.filled_state == 1
                worksheet.write(@row_value,5,"Full")
              elsif kit_filling.filled_state == 2
                worksheet.write(@row_value,5,"Partial")
              elsif kit_filling.filled_state == 0
                worksheet.write(@row_value,5,"Empty")
              else
              end
            end
            worksheet.write(@row_value,6,kit_filling.location_name)
            worksheet.write(@row_value,7,kit_filling.order_no_closed)
            worksheet.write(@row_value,8,kit_filling.scancode_closed)
            worksheet.write(@row_value,9,kit_filling.created_at.strftime("%I:%M%p"))
            worksheet.write(@row_value,10,kit_filling.created_at.to_date)
            @row_value = @row_value+0
            worksheet.write(@row_value, border)
          end
        end
        workbook.close
        send_file Rails.public_path+"/excel/Order Fulfillment Tracking Report.xls",
                  :disposition => "attachment"
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action fetches all the records from TurnReportDetail Table in the selected date and writes the data to csv
    ##
    def turn_count
      require "csv"
      if can?(:>=, "2")
        unless ((params["begin_date3"]) == "") || ((params["end_date3"] == ""))
          @report_data = 	Kitting::TurnReportDetail.where(:cust_no => current_customer.cust_no, :created_at => (Date.strptime(params["begin_date3"].to_s, "%m%d%Y").midnight) - 1.day..Date.strptime(params["end_date3"].to_s, "%m%d%Y").midnight + 1.day).
              select("sum(turns_copy1) as tc1, sum(turns_copy2) as tc2, sum(turns_copy3) as tc3, sum(turns_copy4) as tc4, sum(turns_copy5) as tc5 ,sum(turns_copy6) as tc6, sum(turns_copy7) as tc7, sum(turns_copy8) as tc8,
													sum(turns_copy9) as tc9, sum(turns_copy10) as tc10, kit_number, sub_kit_number, cup_no, part_number, kit_description, kit_media_type, part_description")
                              .group("kit_number, sub_kit_number, cup_no, part_number, kit_description, kit_media_type, part_description").order("kit_number")
        end

        File.open(Rails.public_path+"/excel/Turn Count Report.csv", "w") do |csv|
          csv << "Kit Number,Kit Description,Kit Media Type, Compartment,Part Number,Part Description,Total Turns" +
              ",Turns Copy 1,Turns Copy 2,Turns Copy 3, Turns Copy 4,Turns Copy 5,Turns Copy 6,Turns Copy 7,Turns Copy 8" +
              ",Turns Copy 9,Turns Copy 10\n"
          @report_data.each do |data|
            if data.part_description.blank?
              data.part_description = "No Description"
            end
            if data.kit_description.present?
              data.kit_description.chomp!
              data.kit_description.gsub!("\n",".")
            else
              data.kit_description = "No Description"
            end

            if data.sub_kit_number
              new_cup_no = data.sub_kit_number.to_s + ' : ' + data.cup_no.to_s
            else
              new_cup_no = data.cup_no.to_s
            end

            total_count = data.tc1 + data.tc2 + data.tc3 + data.tc4 + data.tc5 +
                data.tc6 + data.tc7 + data.tc8 + data.tc9 + data.tc10
            csv << "#{data.kit_number},#{data.kit_description.split(',').join('-')},#{data.kit_media_type},"+
                "#{new_cup_no},#{data.part_number},#{data.part_description.split(',').join('-')},"+
                "#{total_count},#{data.tc1},#{data.tc2},#{data.tc3},#{data.tc4},#{data.tc5},#{data.tc6},#{data.tc7},#{data.tc8},#{data.tc9},#{data.tc10}\n"
          end
        end
        send_file(Rails.public_path+"/excel/Turn Count Report.csv",:disposition => "attachment")
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action creates the NEWLY Designed Kits report it fetches data from Kits table for all new kits created in the
    # selected date range
    ##
    def newly_designed_kits
      if can?(:>=, "2")
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = "attachment; filename=Newly Designed Kits Report.xls"
        headers['Cache-Control'] = ''

        # code to create xls file
        require 'writeexcel'
        workbook = WriteExcel.new(Rails.public_path+"/excel/Newly Designed Kits Report.xls")
        worksheet  = workbook.add_worksheet("newly_designed_kits")

        format = workbook.add_format
        border = workbook.add_format
        header = workbook.add_format

        format.set_bold
        border.set_bottom(1)
        header.set_bold
        header.set_header('Big')


        @row_value = 0
        @col_value = 0
        # create a table in xls file

        worksheet.set_column(0, 0, 20)
        worksheet.set_column(0, 1, 20)
        worksheet.set_column(0, 2, 20)
        worksheet.set_column(0, 3, 20)
        worksheet.set_column(0, 4, 20)
        worksheet.set_column(0, 5, 20)
        worksheet.set_column(0, 6, 20)
        worksheet.set_column(0, 7, 20)
        worksheet.set_column(0, 8, 20)
        worksheet.set_column(0, 9, 20)
        worksheet.set_column(0, 10, 20)

        worksheet.write(@row_value, 0,"Newly Designed Kits Report",format)
        @row_value = @row_value+2
        worksheet.write(@row_value, 0,"Customer Number",format)
        worksheet.write(@row_value, 1,"Kit Number",format)
        worksheet.write(@row_value, 2,"Created by",format)
        worksheet.write(@row_value, 3,"Kit Bin Center", format)
        worksheet.write(@row_value, 4,"Part Bin Center",format)
        worksheet.write(@row_value, 5,"Time",format)
        worksheet.write(@row_value, 6,"Date",format)
        # loop for bin center parts data to show in table

        if ((params["newly_designed_kits_begin_date"]) == "") || ((params["newly_designed_kits_end_date"] == ""))
          @kit = Kitting::Kit.where(:cust_no => session[:customer_number], :commit_status => 1, :commit_id => nil)
        else
          @kit = Kitting::Kit.where(:cust_no => session[:customer_number], :commit_status => 1, :commit_id => nil,:created_at => (Date.strptime(params["newly_designed_kits_begin_date"].to_s, "%m%d%Y").midnight)..Date.strptime(params["newly_designed_kits_end_date"].to_s, "%m%d%Y").midnight + 1.day).includes(:customer).order('created_at asc')
        end
        @kit.each_with_index do |kit|
          if kit.blank?
            "Not Available"
          else
            @row_value = @row_value + 1
            worksheet.write(@row_value,0,session["customer_number"])
            if kit.category == "AD HOC"
              worksheet.write(@row_value,1,kit.customer_kit_part_number)
            else
              worksheet.write(@row_value,1,kit.kit_number)
            end
            worksheet.write(@row_value,2,kit.customer.user_name)
            worksheet.write(@row_value,3,kit.bincenter)
            worksheet.write(@row_value,4,kit.part_bincenter)
            worksheet.write(@row_value,5,kit.created_at.strftime("%I:%M%p"))
            worksheet.write(@row_value,6,kit.created_at.to_date)
            @row_value = @row_value+0
            worksheet.write(@row_value, border)
          end
        end
        workbook.close
        send_file Rails.public_path+"/excel/Newly Designed Kits Report.xls",
                  :disposition => "attachment"
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action creates a Kit Fill Metrics report which is used to track kits fills data per each user.
    ##
    def kit_fill_metrics
      if can?(:>=, "2")
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = "attachment; filename=Kit Fill Metrics Report.xls"
        headers['Cache-Control'] = ''

        require 'writeexcel'
        workbook = WriteExcel.new(Rails.public_path+"/excel/Kit Fill Metrics Report.xls")
        worksheet  = workbook.add_worksheet("kit_fill_metrics")

        format = workbook.add_format(:border  => 1,:valign  => 'vcenter',
                                     :align   => 'center')
        column_header_format = workbook.add_format(:border  => 1,:valign  => 'vcenter',
                                                   :align   => 'center')
        border = workbook.add_format(:border  => 1)
        header = workbook.add_format

        ##Setting Format

        format.set_bold
        column_header_format.set_bold
        border.set_bottom(1)
        header.set_bold
        header.set_header('Big')

        ## Setting Columns and Headers
        worksheet.set_column(0, 0, 20)
        worksheet.set_column(0, 1, 20)
        worksheet.set_column(0, 2, 20)
        worksheet.set_column(0, 3, 20)
        worksheet.set_column('B:B', 35)
        worksheet.set_column('G:G', 35)
        worksheet.set_column('H:H', 30)
        worksheet.set_column('I:I', 30)
        worksheet.merge_range('A1:I2',"Kit Fill Metrics Report",format)
        worksheet.merge_range('A3:D4',"Detail Metrics Report",format)
        worksheet.merge_range('G3:I4',"User Wise metrics",format)

        ## Calculating row and column values Writing into Column Headers for Overall Detail metrics data.
        @row_value = 4
        @col_value = 0
        worksheet.write(@row_value, 0,"Ship Date",column_header_format)
        worksheet.write(@row_value, 1,"User Name",column_header_format)
        worksheet.write(@row_value, 2,"Cups Filled",column_header_format)
        worksheet.write(@row_value, 3,"Kits Completed", column_header_format)

        if ((params["kit_fill_metrics_begin_date"]) == "") || ((params["kit_fill_metrics_end_date"] == ""))
          worksheet.merge_range('A1:I2',"Please Select Proper Date Range",format)
        else
          ## Query for overall kit metrics user_wise + date_wise
          @kit_metrics = Kitting::KitOrderFulfillment.find_by_sql(["SELECT TO_CHAR(KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT, 'MM-DD-YYYY') AS completion_date,KITTING_KIT_ORDER_FULFILLMENTS.USER_NAME,
                                                                  SUM(KIT_FILLING_DETAILS.TURN_COUNT) AS Cups_Filled, COUNT(DISTINCT KITTING_KIT_ORDER_FULFILLMENTS.KIT_NUMBER) AS kits_completed
                                                                  FROM KITTING_KIT_ORDER_FULFILLMENTS
                                                                  INNER JOIN KIT_FILLING_DETAILS
                                                                  ON KITTING_KIT_ORDER_FULFILLMENTS.KIT_FILLING_ID = KIT_FILLING_DETAILS.KIT_FILLING_ID
                                                                  WHERE KITTING_KIT_ORDER_FULFILLMENTS.CUST_NO   = ?
                                                                  AND KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT BETWEEN ? AND ?
                                                                  GROUP BY TO_CHAR(KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT, 'MM-DD-YYYY'),
                                                                  KITTING_KIT_ORDER_FULFILLMENTS.USER_NAME
                                                                  ORDER BY TO_DATE(TO_CHAR(KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT, 'MM-DD-YYYY'), 'MM-DD-YYYY')",
                                                                   current_customer.cust_no,
                                                                   Date.strptime(params["kit_fill_metrics_begin_date"].to_s,"%m%d%Y").midnight, Date.strptime(params["kit_fill_metrics_end_date"].to_s,"%m%d%Y").midnight + 1.day
                                                                  ])
          ## Writing actual kit metrics values in corresponding rows and columns.
          @kit_metrics.each_with_index do |kit_metric|
            @row_value = @row_value + 1
            worksheet.write(@row_value,0,kit_metric.completion_date,border)
            worksheet.write(@row_value,1,kit_metric.user_name,border)
            worksheet.write(@row_value,2,kit_metric.cups_filled,border)
            worksheet.write(@row_value,3,kit_metric.kits_completed,border)
          end

          ## Calculating row and column values Writing into Column Headers User-Wise metrics.
          @user_col_value = 6
          @user_row_value = 4
          worksheet.write(@user_row_value, 6,"User Name",column_header_format)
          worksheet.write(@user_row_value, 7,"Total Cups Filled",column_header_format)
          worksheet.write(@user_row_value, 8,"Total Kits Completed",column_header_format)

          ## Data for user wise metrics
          if @kit_metrics.length > 0
            @user_metrics_array = @kit_metrics.group_by(&:user_name).flatten

            ## Writing actual user wise metrics values in corresponding rows and columns.
            @user_cups_total = 0
            @user_kits_total = 0
            @user_metrics_array.each_with_index do |user_metric,user_metric_index|
              if user_metric_index%2 == 1
                @user_cups_total += user_metric.sum(&:cups_filled)
                @user_kits_total += user_metric.sum(&:kits_completed)
                @user_row_value = @user_row_value + 1
                worksheet.write(@user_row_value,6,user_metric.map(&:user_name).uniq,border)
                worksheet.write(@user_row_value,7,user_metric.sum(&:cups_filled),border)
                worksheet.write(@user_row_value,8,user_metric.sum(&:kits_completed),border)
              end
            end
            @user_row_value = @user_row_value + 1
            worksheet.write(@user_row_value, 6,"Total",column_header_format)
            worksheet.write(@user_row_value, 7,@user_cups_total,border)
            worksheet.write(@user_row_value, 8,@user_kits_total,border)
          end

          ## Calculating row and column values Writing into Column Headers for Date-Wise metrics.
          @date_row_value = @user_row_value + 3
          @date_headers_value = @user_row_value + 4
          @date_col_value = 6
          worksheet.merge_range("G#{@date_row_value}:I#{@date_row_value + 1}", "Date Wise metrics",format)
          worksheet.write(@date_headers_value, 6,"Ship Date",column_header_format)
          worksheet.write(@date_headers_value, 7,"Total Cups Filled",column_header_format)
          worksheet.write(@date_headers_value, 8,"Total Kits Completed",column_header_format)
          @date_row_value = @date_row_value + 1

          ## Data for Date wise metrics
          if @kit_metrics.length > 0
            @date_metrics_array = @kit_metrics.group_by(&:completion_date).flatten

            ## Writing actual user wise metrics values in corresponding rows and columns.
            @date_wise_cups_total = 0
            @date_wise_kits_total = 0
            @date_metrics_array.each_with_index do |date_metric,date_metric_index|
              if date_metric_index%2 == 1
                @date_wise_cups_total += date_metric.sum(&:cups_filled)
                @date_wise_kits_total += date_metric.sum(&:kits_completed)
                @date_row_value = @date_row_value + 1
                worksheet.write(@date_row_value,6,date_metric.map(&:completion_date).uniq,border)
                worksheet.write(@date_row_value,7,date_metric.sum(&:cups_filled),border)
                worksheet.write(@date_row_value,8,date_metric.sum(&:kits_completed),border)
              end
            end
            @date_row_value = @date_row_value + 1
            worksheet.write(@date_row_value, 6,"Total",column_header_format)
            worksheet.write(@date_row_value, 7,@date_wise_cups_total,border)
            worksheet.write(@date_row_value, 8,@date_wise_kits_total,border)
          end
          workbook.close
          send_file Rails.public_path+"/excel/Kit Fill Metrics Report.xls",
                    :disposition => "attachment"
        end
      end
    end

    ##
    # This action creates Line and Bar Charts for Kit Fill Metrics report.
    ##
    def view_charts
      # Query for user_name wise metrics.
      user_metrics = Kitting::KitOrderFulfillment.find_by_sql(["SELECT user_name,SUM(count_kits_completed) AS kits_completed,
                                                                  SUM(Sum_Cups_Filled) AS Cups_Filled
                                                                  FROM(SELECT TO_CHAR(KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT, 'MM-DD-YYYY') AS completion_date,
                                                                  KITTING_KIT_ORDER_FULFILLMENTS.USER_NAME AS user_name,
                                                                  SUM(KIT_FILLING_DETAILS.TURN_COUNT) AS Sum_Cups_Filled, COUNT(DISTINCT KITTING_KIT_ORDER_FULFILLMENTS.KIT_NUMBER) AS count_kits_completed
                                                                  FROM KITTING_KIT_ORDER_FULFILLMENTS
                                                                  INNER JOIN KIT_FILLING_DETAILS
                                                                  ON KITTING_KIT_ORDER_FULFILLMENTS.KIT_FILLING_ID = KIT_FILLING_DETAILS.KIT_FILLING_ID
                                                                  WHERE KITTING_KIT_ORDER_FULFILLMENTS.CUST_NO   = ?
                                                                  AND KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT BETWEEN ? AND ?
                                                                  GROUP BY TO_CHAR(KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT, 'MM-DD-YYYY'),KITTING_KIT_ORDER_FULFILLMENTS.USER_NAME)
                                                                  GROUP BY user_name",
                                                               current_customer.cust_no,
                                                               Date.strptime(params["kit_fill_metrics_begin_date"].to_s,"%m/%d/%Y").midnight, Date.strptime(params["kit_fill_metrics_end_date"].to_s,"%m/%d/%Y").midnight + 1.day
                                                              ])
      # Compute Max Y Axis Range for user wise metrics graph
      @user_names = user_metrics.map(&:user_name)
      @kits_complete = user_metrics.map(&:kits_completed)
      @cups_filled = user_metrics.map(&:cups_filled)
      @user_max_range = [@cups_filled, @kits_complete].flatten.max || 1000
      @user_max_range = (@user_max_range/10)*10 + 10

      # Query for date_wise metrics.
      date_metrics = Kitting::KitOrderFulfillment.find_by_sql(["SELECT completion_date,SUM(count_cups) AS cups_filled,SUM(count_kits) AS kits_completed  from
                                                                      (SELECT TO_CHAR(KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT, 'MM-DD-YYYY') AS completion_date,
                                                                      SUM(KIT_FILLING_DETAILS.TURN_COUNT) AS count_cups, COUNT(DISTINCT KITTING_KIT_ORDER_FULFILLMENTS.KIT_NUMBER) AS count_kits
                                                                      FROM KITTING_KIT_ORDER_FULFILLMENTS
                                                                      INNER JOIN KIT_FILLING_DETAILS
                                                                      ON KITTING_KIT_ORDER_FULFILLMENTS.KIT_FILLING_ID = KIT_FILLING_DETAILS.KIT_FILLING_ID
                                                                      WHERE KITTING_KIT_ORDER_FULFILLMENTS.CUST_NO   = ?
                                                                      AND KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT BETWEEN ? AND ?
                                                                      GROUP BY TO_CHAR(KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT, 'MM-DD-YYYY'), KITTING_KIT_ORDER_FULFILLMENTS.USER_NAME
                                                                      ORDER BY TO_CHAR(KITTING_KIT_ORDER_FULFILLMENTS.UPDATED_AT, 'MM-DD-YYYY'))
                                                                      GROUP BY completion_date
                                                                      ORDER BY TO_DATE(completion_date,'MM-DD-YYYY')",
                                                               current_customer.cust_no,
                                                               Date.strptime(params["kit_fill_metrics_begin_date"].to_s,"%m/%d/%Y").midnight, Date.strptime(params["kit_fill_metrics_end_date"].to_s,"%m/%d/%Y").midnight + 1.day
                                                              ])
      # Compute Max Y Axis Range for date wise metrics graph
      @kits_complete_date = date_metrics.map(&:kits_completed)
      @cups_filled_date = date_metrics.map(&:cups_filled)
      @date_max_range = [@cups_filled_date, @kits_complete_date].flatten.max || 1000
      @date_max_range = (@date_max_range/10)*10 + 10

      #Preparing Object Hash to be passed for morris js data.
      @date_hash = Array.new
      date_metrics.map do |key,value|
        @date_hash << { :date => key.completion_date, :cups_filled => key.cups_filled, :kits_completed => key.kits_completed }
      end
      @user_hash = Array.new
      user_metrics.map do |key,value|
        @user_hash << { :user_name =>key.user_name, :cups_filled => key.cups_filled, :kits_completed => key.kits_completed }
      end
    end

    ##
    # This action creates the SOS Kits in process report it fetches data from Kits table for all new kits created in the
    # selected date range
    ##
    def sos_kits_in_process
      if can?(:>=, "2")
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = "attachment; filename=SOS Kits In Process Report.xls"
        headers['Cache-Control'] = ''

        # code to create xls file
        require 'writeexcel'
        workbook = WriteExcel.new(Rails.public_path+"/excel/SOS Kits In Process Report.xls")
        worksheet  = workbook.add_worksheet("sos kits in process")
        worksheet_completed_sos_kits = workbook.add_worksheet("completed kits in sos")

        format = workbook.add_format
        border = workbook.add_format
        header = workbook.add_format

        format.set_bold
        border.set_bottom(1)
        header.set_bold
        header.set_header('Big')

        @row_value = 0
        @col_value = 0
        @row_value_completed_sos_kits = 0
        # create a table in xls file

        worksheet.set_column(0, 0, 20)
        worksheet.set_column(0, 1, 20)
        worksheet.set_column(0, 2, 20)
        worksheet.set_column(0, 3, 20)
        worksheet.set_column(0, 4, 20)
        worksheet.set_column(0, 5, 20)
        worksheet.set_column(0, 6, 20)
        worksheet.set_column(0, 7, 20)
        worksheet.set_column(0, 8, 20)
        worksheet.set_column(0, 9, 20)
        worksheet.set_column(0, 10, 20)
        worksheet.set_column(0, 11, 20) if adhoc_kit_access?

        worksheet.write(@row_value, 0,"SOS Kits In Process Report",format)
        @row_value = @row_value+2
        if adhoc_kit_access?
          worksheet.write(@row_value, 0,"Kit Number",format)
          worksheet.write(@row_value, 1,"Work Order",format)
          worksheet.write(@row_value, 2,"Filled State",format)
          worksheet.write(@row_value, 3,"Detail PN",format)
          worksheet.write(@row_value, 4,"Qty Filled", format)
          worksheet.write(@row_value, 5,"Qty Required",format)
          worksheet.write(@row_value, 6,"Created By",format)
          worksheet.write(@row_value, 7,"Updated At",format)
          worksheet.write(@row_value, 8,"Queue",format)
          worksheet.write(@row_value, 9,"Kit Bin Center",format)
          worksheet.write(@row_value, 10,"Kit Description",format)
          worksheet.write(@row_value, 11,"Media Type",format)

          sos_kits_in_process = Kitting::KitFilling.find_by_sql(["SELECT KITS.CUSTOMER_KIT_PART_NUMBER AS Kit_Number, WORK_ORDERS.ORDER_NUMBER AS Work_Order,
                                                                       KIT_FILLING_DETAILS.FILLED_STATE AS Filled_Status,
                                                                       PARTS.PART_NUMBER AS Detail_PN,
                                                                       KIT_FILLING_DETAILS.FILLED_QUANTITY AS QTY_Filled,
                                                                       CUP_PARTS.DEMAND_QUANTITY AS QTY_Required,
                                                                       KIT_FILLINGS.CREATED_BY,
                                                                       KIT_FILLING_DETAILS.UPDATED_AT,
                                                                       LOCATIONS.NAME AS QUEUE_Name,
                                                                       KITS.BINCENTER AS KIT_Bin_Center,
                                                                       KITS.DESCRIPTION AS KIT_Description,
                                                                       KIT_MEDIA_TYPES.NAME AS MEDIA_Type
                                                                       FROM KIT_FILLINGS INNER JOIN KIT_WORK_ORDERS
                                                                       ON KIT_FILLINGS.KIT_WORK_ORDER_ID = KIT_WORK_ORDERS.ID
                                                                       INNER JOIN KIT_FILLING_DETAILS
                                                                       ON KIT_FILLINGS.ID = KIT_FILLING_DETAILS.KIT_FILLING_ID
                                                                       INNER JOIN CUP_PARTS
                                                                       ON KIT_FILLING_DETAILS.CUP_PART_ID = CUP_PARTS.ID
                                                                       INNER JOIN PARTS
                                                                       ON CUP_PARTS.PART_ID = PARTS.ID
                                                                       INNER JOIN LOCATIONS
                                                                       ON LOCATIONS.ID = KIT_FILLINGS.LOCATION_ID
                                                                       INNER JOIN KITS
                                                                       ON KIT_WORK_ORDERS.KIT_ID = KITS.ID
                                                                       INNER JOIN WORK_ORDERS
                                                                       ON KIT_WORK_ORDERS.WORK_ORDER_ID = WORK_ORDERS.ID
                                                                       INNER JOIN KIT_MEDIA_TYPES
                                                                       ON KITS.KIT_MEDIA_TYPE_ID = KIT_MEDIA_TYPES.ID
                                                                       WHERE KIT_FILLINGS.CREATED_BY   = ?
                                                                       AND KIT_FILLING_DETAILS.FILLED_STATE <> ?
                                                                       AND CUP_PARTS.STATUS = 1
                                                                       AND KIT_FILLINGS.LOCATION_ID = (SELECT id FROM LOCATIONS WHERE name= 'SOS Queue')
                                                                       ORDER BY Kit_Number,Work_Order,Detail_PN",
                                                                 current_customer.cust_no,
                                                                 'F'])
          sos_kits_in_process.each_with_index do |kit|
            @row_value = @row_value + 1
            worksheet.write(@row_value,0,kit["kit_number"])
            worksheet.write(@row_value,1,kit["work_order"])
            worksheet.write(@row_value,2,kit["filled_status"])
            worksheet.write(@row_value,3,kit["detail_pn"])
            worksheet.write(@row_value,4,kit["qty_filled"])
            worksheet.write(@row_value,5,kit["qty_required"])
            worksheet.write(@row_value,6,kit.created_by)
            worksheet.write(@row_value,7,kit.updated_at.strftime("%Y-%m-%d %I:%M%p"))
            worksheet.write(@row_value,8,kit["queue_name"])
            worksheet.write(@row_value,9,kit["kit_bin_center"])
            worksheet.write(@row_value,10,kit["kit_description"])
            worksheet.write(@row_value,11,kit["media_type"])
            @row_value = @row_value+0
            worksheet.write(@row_value, border)
          end
        else
          worksheet.write(@row_value, 0,"Kit Copy",format)
          worksheet.write(@row_value, 1,"Filled State",format)
          worksheet.write(@row_value, 2,"Detail PN",format)
          worksheet.write(@row_value, 3,"Qty Filled", format)
          worksheet.write(@row_value, 4,"Qty Required",format)
          worksheet.write(@row_value, 5,"Created By",format)
          worksheet.write(@row_value, 6,"Updated At",format)
          worksheet.write(@row_value, 7,"Queue",format)
          worksheet.write(@row_value, 8,"Kit Bin Center",format)
          worksheet.write(@row_value, 9,"Kit Description",format)
          worksheet.write(@row_value, 10,"Media Type",format)
          # loop for bin center parts data to show in table
          sos_kits_in_process = Kitting::KitFilling.find_by_sql(["SELECT KIT_COPIES.KIT_VERSION_NUMBER AS Kit_Copy,
                                                                       KIT_FILLING_DETAILS.FILLED_STATE AS Filled_Status,
                                                                       PARTS.PART_NUMBER AS Detail_PN,
                                                                       KIT_FILLING_DETAILS.FILLED_QUANTITY AS QTY_Filled,
                                                                       CUP_PARTS.DEMAND_QUANTITY AS QTY_Required,
                                                                       KIT_FILLINGS.CREATED_BY,
                                                                       KIT_FILLING_DETAILS.UPDATED_AT,
                                                                       LOCATIONS.NAME AS QUEUE_Name,
                                                                       KITS.BINCENTER AS KIT_Bin_Center,
                                                                       KITS.DESCRIPTION AS KIT_Description,
                                                                       KIT_MEDIA_TYPES.NAME AS MEDIA_Type
                                                                       FROM KIT_FILLINGS INNER JOIN KIT_COPIES
                                                                       ON KIT_FILLINGS.KIT_COPY_ID = KIT_COPIES.ID
                                                                       INNER JOIN KIT_FILLING_DETAILS
                                                                       ON KIT_FILLINGS.ID = KIT_FILLING_DETAILS.KIT_FILLING_ID
                                                                       INNER JOIN CUP_PARTS
                                                                       ON KIT_FILLING_DETAILS.CUP_PART_ID = CUP_PARTS.ID
                                                                       INNER JOIN PARTS
                                                                       ON CUP_PARTS.PART_ID = PARTS.ID
                                                                       INNER JOIN LOCATIONS
                                                                       ON LOCATIONS.ID = KIT_FILLINGS.LOCATION_ID
                                                                       INNER JOIN KITS
                                                                       ON KIT_COPIES.KIT_ID = KITS.ID
                                                                       INNER JOIN KIT_MEDIA_TYPES
                                                                       ON KITS.KIT_MEDIA_TYPE_ID = KIT_MEDIA_TYPES.ID
                                                                       WHERE KIT_FILLINGS.CREATED_BY   = ?
                                                                       AND KIT_FILLING_DETAILS.FILLED_STATE <> ?
                                                                       AND CUP_PARTS.STATUS = 1
                                                                       AND KIT_FILLINGS.LOCATION_ID = (SELECT id FROM LOCATIONS WHERE name= 'SOS Queue')
                                                                       ORDER BY KIT_Copy,Detail_PN",
                                                                 current_customer.cust_no,
                                                                 'F'])
          sos_kits_in_process.each_with_index do |kit|
            @row_value = @row_value + 1
            worksheet.write(@row_value,0,kit["kit_copy"])
            worksheet.write(@row_value,1,kit["filled_status"])
            worksheet.write(@row_value,2,kit["detail_pn"])
            worksheet.write(@row_value,3,kit["qty_filled"])
            worksheet.write(@row_value,4,kit["qty_required"])
            worksheet.write(@row_value,5,kit.created_by)
            worksheet.write(@row_value,6,kit.updated_at.strftime("%Y-%m-%d %I:%M%p"))
            worksheet.write(@row_value,7,kit["queue_name"])
            worksheet.write(@row_value,8,kit["kit_bin_center"])
            worksheet.write(@row_value,9,kit["kit_description"])
            worksheet.write(@row_value,10,kit["media_type"])
            @row_value = @row_value+0
            worksheet.write(@row_value, border)
          end
        end

        # create a table in xls file
        worksheet_completed_sos_kits.set_column(0, 0, 40)
        worksheet_completed_sos_kits.set_column(0, 1, 20)
        worksheet_completed_sos_kits.set_column(0, 2, 20)
        worksheet_completed_sos_kits.set_column(0, 3, 20)
        worksheet_completed_sos_kits.set_column(0, 4, 20)
        worksheet_completed_sos_kits.set_column(0, 5, 20)
        worksheet_completed_sos_kits.set_column(0, 6, 20)
        worksheet_completed_sos_kits.set_column(0, 7, 20) if adhoc_kit_access?

        worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 0,"SOS Kits In Process Report",format)
        @row_value_completed_sos_kits = @row_value_completed_sos_kits+2
        if adhoc_kit_access?
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 0,"Kit Number",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 1,"Work Order",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 2,"Created By",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 3,"Updated At",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 4,"Queue",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 5,"Kit Bin Center",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 6,"Kit Description",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 7,"Media Type",format)

          # loop for bin center parts data to show in table
          completed_sos_kits_in_process = Kitting::KitFilling.find_by_sql(["SELECT KITS.CUSTOMER_KIT_PART_NUMBER AS Kit_Number,
                                                                       Work_Orders.order_number As Work_Order,
                                                                       KIT_FILLINGS.CREATED_BY,
                                                                       KIT_FILLINGS.UPDATED_AT,
                                                                       LOCATIONS.NAME AS QUEUE_Name,
                                                                       KITS.BINCENTER AS KIT_Bin_Center,
                                                                       KITS.DESCRIPTION AS KIT_Description,
                                                                       KIT_MEDIA_TYPES.NAME AS MEDIA_Type
                                                                       FROM KIT_FILLINGS INNER JOIN KIT_WORK_ORDERS
                                                                       ON KIT_FILLINGS.KIT_WORK_ORDER_ID = KIT_WORK_ORDERS.ID
                                                                       INNER JOIN LOCATIONS
                                                                       ON LOCATIONS.ID = KIT_FILLINGS.LOCATION_ID
                                                                       INNER JOIN KITS
                                                                       ON KIT_WORK_ORDERS.KIT_ID = KITS.ID
                                                                       INNER JOIN WORK_ORDERS
                                                                       ON KIT_WORK_ORDERS.WORK_ORDER_ID = WORK_ORDERS.ID
                                                                       INNER JOIN KIT_MEDIA_TYPES
                                                                       ON KITS.KIT_MEDIA_TYPE_ID = KIT_MEDIA_TYPES.ID
                                                                       WHERE KIT_FILLINGS.CREATED_BY   = ?
                                                                       AND KIT_FILLINGS.FILLED_STATE = ?
                                                                       AND KIT_FILLINGS.LOCATION_ID = (SELECT id FROM LOCATIONS WHERE name= 'SOS Queue')
                                                                       ORDER BY Kit_Number,Work_Order",
                                                                           current_customer.cust_no,
                                                                           1])
          completed_sos_kits_in_process.each_with_index do |kit|
            @row_value_completed_sos_kits = @row_value_completed_sos_kits + 1
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,0,kit["kit_number"])
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,1,kit["work_order"])
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,2,kit.created_by)
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,3,kit.updated_at.strftime("%Y-%m-%d %I:%M%p"))
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,4,kit["queue_name"])
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,5,kit["kit_bin_center"])
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,6,kit["kit_description"])
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,7,kit["media_type"])
            @row_value_completed_sos_kits = @row_value_completed_sos_kits+0
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, border)
          end
        else
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 0,"Kit Copy",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 1,"Created By",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 2,"Updated At",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 3,"Queue",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 4,"Kit Bin Center",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 5,"Kit Description",format)
          worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, 6,"Media Type",format)

          # loop for bin center parts data to show in table
          completed_sos_kits_in_process = Kitting::KitFilling.find_by_sql(["SELECT KIT_COPIES.KIT_VERSION_NUMBER AS Kit_Copy,
                                                                       KIT_FILLINGS.CREATED_BY,
                                                                       KIT_FILLINGS.UPDATED_AT,
                                                                       LOCATIONS.NAME AS QUEUE_Name,
                                                                       KITS.BINCENTER AS KIT_Bin_Center,
                                                                       KITS.DESCRIPTION AS KIT_Description,
                                                                       KIT_MEDIA_TYPES.NAME AS MEDIA_Type
                                                                       FROM KIT_FILLINGS INNER JOIN KIT_COPIES
                                                                       ON KIT_FILLINGS.KIT_COPY_ID = KIT_COPIES.ID
                                                                       INNER JOIN LOCATIONS
                                                                       ON LOCATIONS.ID = KIT_FILLINGS.LOCATION_ID
                                                                       INNER JOIN KITS
                                                                       ON KIT_COPIES.KIT_ID = KITS.ID
                                                                       INNER JOIN KIT_MEDIA_TYPES
                                                                       ON KITS.KIT_MEDIA_TYPE_ID = KIT_MEDIA_TYPES.ID
                                                                       WHERE KIT_FILLINGS.CREATED_BY   = ?
                                                                       AND KIT_FILLINGS.FILLED_STATE = ?
                                                                       AND KIT_FILLINGS.LOCATION_ID = (SELECT id FROM LOCATIONS WHERE name= 'SOS Queue')
                                                                       ORDER BY KIT_Copy",
                                                                           current_customer.cust_no,
                                                                           1])
          completed_sos_kits_in_process.each_with_index do |kit|
            @row_value_completed_sos_kits = @row_value_completed_sos_kits + 1
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,0,kit["kit_copy"])
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,1,kit.created_by)
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,2,kit.updated_at.strftime("%Y-%m-%d %I:%M%p"))
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,3,kit["queue_name"])
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,4,kit["kit_bin_center"])
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,5,kit["kit_description"])
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits,6,kit["media_type"])
            @row_value_completed_sos_kits = @row_value_completed_sos_kits+0
            worksheet_completed_sos_kits.write(@row_value_completed_sos_kits, border)
          end
        end

        workbook.close
        send_file Rails.public_path+"/excel/SOS Kits In Process Report.xls",
                  :disposition => "attachment"
      else
        redirect_to main_app.unauthorized_url
      end
    end

    def returned_parts_details
      if can?(:>=, "2")
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = "attachment; filename=Returned_Parts_Details_Report.xls"
        headers['Cache-Control'] = ''

        # code to create xls file
        require 'writeexcel'
        workbook = WriteExcel.new(Rails.public_path+"/excel/Returned_Parts_Details_Report.xls")
        worksheet  = workbook.add_worksheet("returned_parts_details")

        format = workbook.add_format
        border = workbook.add_format
        header = workbook.add_format

        format.set_bold
        border.set_bottom(1)
        header.set_bold
        header.set_header('Big')

        @row_value = 0
        @col_value = 0
        # create a table in xls file

        worksheet.set_column(0, 0, 20)
        worksheet.set_column(0, 1, 20)
        worksheet.set_column(0, 2, 20)
        worksheet.set_column(0, 3, 20)
        worksheet.set_column(0, 4, 20)
        worksheet.set_column(0, 5, 20)
        worksheet.set_column(0, 6, 20)
        worksheet.set_column(0, 7, 20)
        worksheet.set_column(0, 8, 20)
        worksheet.set_column(0, 9, 20)
        worksheet.set_column(0, 10, 20)

        worksheet.write(@row_value, 0,"Returned Parts Details Report",format)
        @row_value = @row_value+2
        worksheet.write(@row_value, 0,"Work Order",format)
        worksheet.write(@row_value, 1,"Job Card No",format)
        worksheet.write(@row_value, 2,"Job Card Desc",format)
        worksheet.write(@row_value, 3,"Stage", format)
        worksheet.write(@row_value, 4,"Aircraft Serial No",format)
        worksheet.write(@row_value, 5,"Detail Part No",format)
        worksheet.write(@row_value, 6,"Qty",format)
        worksheet.write(@row_value, 7,"Date Completed",format)
        worksheet.write(@row_value, 8,"Date Returned",format)
        worksheet.write(@row_value, 9,"Original Req Type",format)
        worksheet.write(@row_value, 10,"Requestor",format)

        if ((params["returned_parts_begin_date"]) != "") && ((params["returned_parts_end_date"] != "")) && adhoc_kit_access?
          returned_details = Kitting::ReturnedPartDetail.where(:cust_no => current_user,:created_at => (Date.strptime(params["returned_parts_begin_date"].to_s, "%m%d%Y").midnight)..Date.strptime(params["returned_parts_end_date"].to_s, "%m%d%Y").midnight + 1.day).order('created_at asc')
          returned_details.each do |returned_part|
            @row_value = @row_value + 1
            worksheet.write(@row_value,0,returned_part.work_order)
            worksheet.write(@row_value,1,returned_part.job_card_number)
            worksheet.write(@row_value,2,returned_part.job_card_description)
            worksheet.write(@row_value,3,returned_part.stage)
            worksheet.write(@row_value,4,returned_part.serial_number)
            worksheet.write(@row_value,5,returned_part.part_number)
            worksheet.write(@row_value,6,returned_part.quantity)
            worksheet.write(@row_value,7,returned_part.date_completed.to_date.strftime("%m/%d/%Y"))
            worksheet.write(@row_value,8,returned_part.created_at.to_date.strftime("%m/%d/%Y"))
            worksheet.write(@row_value,9,returned_part.request_type)
            worksheet.write(@row_value,10,returned_part.requestor)
          end
          workbook.close
          send_file Rails.public_path+"/excel/Returned_Parts_Details_Report.xls",
                    :disposition => "attachment"
        else
          workbook.close
          send_file Rails.public_path+"/excel/Returned_Parts_Details_Report.xls",
                    :disposition => "attachment"
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    def kit_work_order_status
      if can?(:>=, "2")
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = "attachment; filename=Kit_Status_Report.xls"
        headers['Cache-Control'] = ''

        require 'writeexcel'
        workbook = WriteExcel.new(Rails.public_path+"/excel/Kit_Status_Report.xls")
        worksheet  = workbook.add_worksheet("kit_status")

        format = workbook.add_format
        border = workbook.add_format
        header = workbook.add_format

        format.set_bold
        border.set_bottom(1)
        header.set_bold
        header.set_header('Big')

        @row_value = 0
        @col_value = 0
        # create a table in xls file

        worksheet.set_column(0, 0, 20)
        worksheet.set_column(0, 1, 20)
        worksheet.set_column(0, 2, 20)
        worksheet.set_column(0, 3, 20)
        worksheet.set_column(0, 4, 20)
        worksheet.set_column(0, 5, 20)
        worksheet.set_column(0, 6, 20)
        worksheet.set_column(0, 7, 20)
        worksheet.set_column(0, 8, 20)

        worksheet.write(@row_value, 0,"Kit_Status Report",format)
        @row_value = @row_value+2
        worksheet.write(@row_value, 0,"Work Order",format)
        worksheet.write(@row_value, 1,"Job Card No",format)
        worksheet.write(@row_value, 2,"Job Card Desc",format)
        worksheet.write(@row_value, 3,"Stage", format)
        worksheet.write(@row_value, 4,"Aircraft Serial No",format)
        worksheet.write(@row_value, 5,"Requirement Date",format)
        worksheet.write(@row_value, 6,"Completed Date",format)
        worksheet.write(@row_value, 7,"Kit Status",format)
        worksheet.write(@row_value, 8,"Sent Complete",format)
        if ((params["kit_status_begin_date"]) != "") && ((params["kit_status_end_date"] != "")) && adhoc_kit_access?
          kit_fillings_for_status = Kitting::KitFilling.where(:created_by => current_user,:updated_at => (Date.strptime(params["kit_status_begin_date"].to_s, "%m%d%Y").midnight)..Date.strptime(params["kit_status_end_date"].to_s, "%m%d%Y").midnight + 1.day)
          all_status_arr = []
          kit_fillings_for_status.each do |kit_filling|
            work_order_number = kit_filling.kit_work_order.work_order.order_number rescue "Not Found"
            job_card_number = kit_filling.kit_work_order.kit.customer_kit_part_number rescue "Not Found"
            job_card_description = kit_filling.kit_work_order.kit.description rescue ""
            stage = kit_filling.kit_work_order.work_order.stage rescue ""
            aircft_serial_number = kit_filling.kit_work_order.work_order.serial_number rescue ""
            requirement_date = kit_filling.kit_work_order.due_date
            completed_date = kit_filling.updated_at
            kit_status = kit_filling.location.name rescue ""
            sent_complete = kit_filling.flag ? "No" : "Yes"
            kit_status_hash = {
                work_order: work_order_number,
                job_card: job_card_number,
                job_card_description: job_card_description,
                stage: stage,
                aircft_serial_number: aircft_serial_number,
                requirement_date: requirement_date,
                completed_date: completed_date,
                kit_status: kit_status,
                sent_complete: sent_complete
            }
            all_status_arr << kit_status_hash
          end
          all_status_arr = all_status_arr.sort_by {|all_kits| all_kits[:work_order] || ""}
          all_status_arr.each_with_index do |kit_details,index|
            @row_value = @row_value + 1
            worksheet.write(@row_value,0,kit_details[:work_order])
            worksheet.write(@row_value,1,kit_details[:job_card])
            worksheet.write(@row_value,2,kit_details[:job_card_description])
            worksheet.write(@row_value,3,kit_details[:stage])
            worksheet.write(@row_value,4,kit_details[:aircft_serial_number])
            worksheet.write(@row_value,5,kit_details[:requirement_date].to_date.strftime("%m/%d/%Y"))
            worksheet.write(@row_value,6,kit_details[:completed_date].to_date.strftime("%m/%d/%Y"))
            worksheet.write(@row_value,7,kit_details[:kit_status])
            worksheet.write(@row_value,8,kit_details[:sent_complete])
          end
          workbook.close
          send_file Rails.public_path+"/excel/Kit_Status_Report.xls",
                    :disposition => "attachment"
        else
          workbook.close
          send_file Rails.public_path+"/excel/Kit_Status_Report.xls",
                    :disposition => "attachment"
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    def delivery
      if can?(:>=, "2")
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = "attachment; filename=Delivery_Report.xls"
        headers['Cache-Control'] = ''

        require 'writeexcel'
        workbook = WriteExcel.new(Rails.public_path+"/excel/Delivery_Report.xls")
        worksheet  = workbook.add_worksheet("delivery")

        format = workbook.add_format
        border = workbook.add_format
        header = workbook.add_format

        format.set_bold
        border.set_bottom(1)
        header.set_bold
        header.set_header('Big')

        @row_value = 0
        @col_value = 0
        # create a table in xls file

        worksheet.set_column(0, 0, 25)
        worksheet.set_column(0, 1, 25)
        worksheet.set_column(0, 2, 25)
        worksheet.set_column(0, 3, 25)
        worksheet.set_column(0, 4, 25)

        worksheet.write(@row_value, 0,"Delivery_Report",format)
        @row_value = @row_value+2
        worksheet.write(@row_value, 0,"Delivery ID",format)
        worksheet.write(@row_value, 1,"Kit Part Number",format)
        worksheet.write(@row_value, 2,"Delivery Point",format)
        worksheet.write(@row_value, 3,"Delivery Time", format)
        worksheet.write(@row_value, 4,"Request Time/ Due Date",format)

        if ((params["delivery_begin_date"]) != "") && ((params["delivery_end_date"] != "")) && adhoc_kit_access?
          @delivered_orders = Kitting::KitOrderFulfillment.where(:cust_no => current_user,
                                                                 :delivery_date => (Date.strptime(params["delivery_begin_date"].to_s, "%m%d%Y").midnight)..Date.strptime(params["delivery_end_date"].to_s, "%m%d%Y").midnight + 1.day, :delivered => true)
          @delivered_orders.each_with_index do |del_order,index|
            if del_order.present?
              delivery_id = del_order.kit_filling_id rescue ""
              kit_number = del_order.kit_number rescue ""
              del_point = del_order.delivery_point rescue ""
              del_time = del_order.delivery_date.in_time_zone("UTC").strftime("%m-%d-%Y %I:%M%p") rescue ""
              req_time = del_order.kit_filling.kit_work_order.due_date.strftime("%m-%d-%Y %I:%M%p") rescue ""
              @row_value = @row_value + 1
              worksheet.write(@row_value,0,delivery_id)
              worksheet.write(@row_value,1,kit_number)
              worksheet.write(@row_value,2,del_point)
              worksheet.write(@row_value,3,del_time)
              worksheet.write(@row_value,4,req_time)
            end
          end
          workbook.close
          send_file Rails.public_path+"/excel/Delivery_Report.xls",
                    :disposition => "attachment"
        else
          workbook.close
          send_file Rails.public_path+"/excel/Delivery_Report.xls",
                    :disposition => "attachment"
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end
  end
end