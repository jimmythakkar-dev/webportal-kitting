require_dependency "kitting/application_controller"

module Kitting
  class CribPartReportsController < ApplicationController
    before_filter :get_acess_right, :except => [:index,:crib_delivery]
    before_filter :add_headers, :only=>[ :crib_delivery]
    protect_from_forgery
    def index
      if can?(:>=, "2")
      else
        redirect_to main_app.unauthorized_url
      end
    end

    def crib_delivery
      if can?(:>=, "2")
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = "attachment; filename=Crib_Delivery_Report.xls"
        headers['Cache-Control'] = ''

        require 'writeexcel'
        workbook = WriteExcel.new(Rails.public_path+"/excel/Crib_Delivery_Report.xls")
        worksheet  = workbook.add_worksheet("crib_delivery")

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
        worksheet.set_column(0, 5, 25)

        worksheet.write(@row_value, 0,"Crib_Delivery_Report",format)
        @row_value = @row_value+2
        worksheet.write(@row_value, 0,"Pack ID",format)
        worksheet.write(@row_value, 1,"Part Number",format)
        worksheet.write(@row_value, 2,"Delivery Point",format)
        worksheet.write(@row_value, 3,"Delivery Time", format)
        worksheet.write(@row_value, 4,"Due Date",format)
        worksheet.write(@row_value, 5,"Request Time",format)
        if ((params["crib_delivery_begin_date"]) != "") && ((params["crib_delivery_end_date"] != "")) && adhoc_kit_access?
          @delivered_orders = OrderPartDetail.joins(:order).where('orders.customer_number' => current_user,
                                                                 :delivery_date => (Date.strptime(params["crib_delivery_begin_date"].to_s, "%m%d%Y").midnight)..Date.strptime(params["crib_delivery_end_date"].to_s, "%m%d%Y").midnight + 1.day, :delivered => true)
          @delivered_orders.each_with_index do |del_order,index|
            if del_order.present?
              pack_id = del_order.pack_id rescue ""
              part_number = del_order.part_number rescue ""
              del_point = del_order.delivery_point rescue ""
              del_time = del_order.delivery_date.in_time_zone("UTC").strftime("%m-%d-%Y %I:%M%p") rescue ""
              due_time = del_order.order.due_date.strftime("%m-%d-%Y %I:%M%p") rescue ""
              req_time = del_order.created_at.strftime("%m-%d-%Y %I:%M%p") rescue ""
              @row_value = @row_value + 1
              worksheet.write(@row_value,0,pack_id)
              worksheet.write(@row_value,1,part_number)
              worksheet.write(@row_value,2,del_point)
              worksheet.write(@row_value,3,del_time)
              worksheet.write(@row_value,4,due_time)
              worksheet.write(@row_value,5,req_time)
            end
          end
          workbook.close
          send_file Rails.public_path+"/excel/Crib_Delivery_Report.xls",
                    :disposition => "attachment"
        else
          workbook.close
          send_file Rails.public_path+"/excel/Crib_Delivery_Report.xls",
                    :disposition => "attachment"
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end
  end
end