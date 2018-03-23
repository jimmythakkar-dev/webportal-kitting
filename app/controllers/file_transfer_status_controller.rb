class FileTransferStatusController < ApplicationController
  before_filter :get_menu_id
  before_filter :add_headers, :only=>[:download_pick_list_excel,:download_delivery_list_excel]
  def index
    case session[:customer_number]
      when "025424"
        @my_site_code = "MCN"
      when "025352"
        @my_site_code = "STL"
      when "025414"
        @my_site_code = "LB"
      when "025415"
        @my_site_code = "MESA"
      when "029414"
        @my_site_code = "SEA"
      when "029415"
        @my_site_code = "ELS"
      when "029540"
        @my_site_code = "PHL"
      else
        @my_site_code = "MESA"
    end

    if params[:grid_key] && params[:act] && params[:act] == "PLD"
      @boeing_pay_load_detail = RemoteDB.connection.select_all("SELECT * FROM BOEING_PAYLOADS where id = '"+params[:grid_key]+"'")
    end

    if params[:search_part_number]
      params[:grid_key] = params[:search_part_number].strip.upcase
      params[:act] = "MP"
    end

    if params[:grid_key] && params[:act] && params[:act] == "P"
      @pick_file_list = RemoteDB.connection.select_all("select * from BOEING_PICK_FILE where FILENAME = '"+ params[:grid_key]+"' and SITE_CODE = '"+@my_site_code+"'").paginate(params[:page], 20)
    elsif params[:grid_key] and params[:act] and params[:act] == "D"
      @delivery_file_list = RemoteDB.connection.select_all("select * from BOEING_DELIVERY_FILE where FILENAME = '"+ params[:grid_key]+"' and SITE_CODE = '"+@my_site_code+"'").paginate(params[:page], 20)
    elsif(params[:grid_key] and params[:act] and (params[:act] == "SP" or params[:act] == "DP" or params[:act] == "MP"))

      if params[:act] and (params[:act] == "SP" or params[:act] == "MP")
        if params[:search_part_number].present?
          @pick_file_details = RemoteDB.connection.select_all( "select * from boeing_pick_file where part_no like '"+ params[:grid_key] + "' and site_code = '"+@my_site_code+"'").paginate(params[:page], 20)
        else
          @pick_file_details = RemoteDB.connection.select_all( "select * from boeing_pick_file where part_no = '"+params[:grid_key] + "' and site_code = '"+@my_site_code+"'").paginate(params[:page], 20)
        end
      end
      if params[:act] and (params[:act] == "DP" or params[:act] == "MP")
        if params[:search_part_number].present?
          @delivery_file_details = RemoteDB.connection.select_all( "select * from boeing_delivery_file where part_no like '"+ params[:grid_key] +"' and site_code = '"+@my_site_code+"'").paginate(params[:page], 20)
        else
          @delivery_file_details = RemoteDB.connection.select_all( "select * from boeing_delivery_file where part_no = '"+params[:grid_key] + "' and site_code = '"+@my_site_code+"'").paginate(params[:page], 20)
        end
      end
    else
      if @my_site_code == "STL"
        @pick_files = RemoteDB.connection.select_all("select distinct filename, create_date, count(part_no) as myPartsCount from boeing_pick_file where site_code = '"+@my_site_code+"' group by filename, create_date order by filename").paginate(params[:page], 20)
      else
        @pick_files = RemoteDB.connection.select_all("select distinct filename, create_date, count(part_no) as myPartsCount from boeing_pick_file where site_code = '"+@my_site_code+"' group by filename, create_date order by filename").paginate(params[:page], 20)
      end
      @delivery_files = RemoteDB.connection.select_all("select distinct filename, create_date, count(part_no) as myPartsCount from boeing_delivery_file where site_code = '"+@my_site_code+"' group by filename, create_date order by filename").paginate(params[:delivery_page], 20)
    end
  end


  def download_pick_list_excel
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = "attachment; filename=BOEING_PICK_FILE.xls"
    headers['Cache-Control'] = ''
    require 'writeexcel'

    workbook = WriteExcel.new(Rails.public_path+"/excel/boeing_pick_files/BOEING_PICK_FILE.xls")
    worksheet  = workbook.add_worksheet("BOEING_PICK_FILE")

    format = workbook.add_format
    format1 = workbook.add_format
    format2 = workbook.add_format
    format.set_bold
    format.set_align('center')
    format1.set_color('red')
    format2.set_align('center')
    worksheet.set_column(0, 0, 20)
    worksheet.set_column(0, 1, 10)
    worksheet.set_column(0, 2, 10)
    worksheet.set_column(0, 3, 10)
    worksheet.set_column(0, 4, 20)
    worksheet.set_column(0, 5, 10)
    worksheet.set_column(0, 6, 20)
    worksheet.set_column(0, 7, 20)
    worksheet.set_column(0, 8, 10)
    worksheet.set_column(0, 9, 10)
    worksheet.set_column(0, 10, 10)
    worksheet.set_column(0, 11, 20)
    worksheet.set_column(0, 12, 10)
    worksheet.set_column(0, 13, 20)
    worksheet.set_column(0, 14, 20)
    worksheet.set_column(0, 15, 10)

    @pick_file_list = RemoteDB.connection.select_all("select * from BOEING_PICK_FILE where FILENAME = '"+ params[:grid_key]+"' and SITE_CODE = '"+params[:my_site_code]+"'")
    @row_value = 1
    worksheet.write(@row_value+1, 0)
    worksheet.write(@row_value+2, 0)

    worksheet.write(@row_value+1, 0, "PICK_FILE:"+ params[:grid_key])
    worksheet.write(@row_value+3, 0, session[:customer_Name],format1)

    worksheet.write(@row_value+5, 0,"PART NUM", format)
    worksheet.write(@row_value+5, 1,"QTY", format)
    worksheet.write(@row_value+5, 2,"UOM", format)
    worksheet.write(@row_value+5, 3,"DEMAND_STOCKROOM", format)
    worksheet.write(@row_value+5, 4,"ORDER_NO", format)
    worksheet.write(@row_value+5, 5,"ORDER_LINE_NO", format)
    worksheet.write(@row_value+5, 6,"DELIVERY_LOCATION", format)
    worksheet.write(@row_value+5, 7,"REQ_DATE", format)
    worksheet.write(@row_value+5, 8,"REQ_SOURCE", format)
    worksheet.write(@row_value+5, 9,"BUS UNIT", format)
    worksheet.write(@row_value+5, 10,"ACTIVITY ID", format)
    worksheet.write(@row_value+5, 11,"DATE / TIME", format)
    worksheet.write(@row_value+5, 12,"SITE CODE", format)
    worksheet.write(@row_value+5, 13,"FILENAME", format)
    worksheet.write(@row_value+5, 14,"CREATED", format)
    worksheet.write(@row_value+5, 15,"PAYLOAD_ID", format)

    @pick_file_list.each_with_index do |file, i|
      worksheet.write(@row_value+6+i,0,file["part_no"],format2)
      worksheet.write(@row_value+6+i,1,file["qty"],format2)
      worksheet.write(@row_value+6+i,2,file["uom"],format2)
      worksheet.write(@row_value+6+i,3,file["demand_stockroom"],format2)
      worksheet.write(@row_value+6+i,4,file["order_no"],format2)
      worksheet.write(@row_value+6+i,5,file["order_line_no"],format2)
      worksheet.write(@row_value+6+i,6,file["delivery_location"],format2)
      worksheet.write(@row_value+6+i,7,file["req_date"],format2)
      worksheet.write(@row_value+6+i,8,file["req_source"],format2)
      worksheet.write(@row_value+6+i,9,file["business_unit"],format2)
      worksheet.write(@row_value+6+i,10,file["activity_id"],format2)
      worksheet.write(@row_value+6+i,11,file["date_time_stamp"],format2)
      worksheet.write(@row_value+6+i,12,file["site_code"],format2)
      worksheet.write(@row_value+6+i,13,file["filename"],format2)
      worksheet.write(@row_value+6+i,14,file["create_date"],format2)
      worksheet.write(@row_value+6+i,15,file["payload_id"],format2)

    end
    workbook.close
    send_file Rails.public_path+"/excel/boeing_pick_files/BOEING_PICK_FILE.xls", :disposition => "attachment"

  end

  def download_delivery_list_excel
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = "attachment; filename=BOEING_DELIVERY_FILE.xls"
    headers['Cache-Control'] = ''
    require 'writeexcel'

    workbook = WriteExcel.new(Rails.public_path+"/excel/boeing_delivery_files/BOEING_DELIVERY_FILE.xls")
    worksheet  = workbook.add_worksheet("BOEING_DELIVERY_FILE")

    format = workbook.add_format
    header = workbook.add_format
    format1 = workbook.add_format
    format2 = workbook.add_format
    format.set_bold
    header.set_bold
    format1.set_color('red')
    format2.set_align('center')
    header.set_align('center')
    worksheet.set_column(0, 0, 20)

    @delivery_file_list = RemoteDB.connection.select_all("select * from BOEING_DELIVERY_FILE where FILENAME = '"+ params[:grid_key]+"' and SITE_CODE = '"+params[:my_site_code]+"'")
    @row_value = 1
    worksheet.write(@row_value+1, 0)
    worksheet.write(@row_value+2, 0)

    worksheet.write(@row_value+1, 0, "DELIVERY_FILE:"+ params[:grid_key])
    worksheet.write(@row_value+3, 0, session[:customer_Name],format1)

    worksheet.write(@row_value+5, 0,"PART NUM", header)
    worksheet.write(@row_value+5, 1,"PART TYPE", header)
    worksheet.write(@row_value+5, 2,"QTY", header)
    worksheet.write(@row_value+5, 3,"UOM", header)
    worksheet.write(@row_value+5, 4,"TO STKRM", header)
    worksheet.write(@row_value+5, 5,"ORDER NO", header)
    worksheet.write(@row_value+5, 6,"ORDER LINE NO", header)
    worksheet.write(@row_value+5, 7,"INVOICE NO", header)
    worksheet.write(@row_value+5, 8,"BIN LINE STN", header)
    worksheet.write(@row_value+5, 9,"ORDER DATE", header)
    worksheet.write(@row_value+5, 10,"DELIVERY DATE", header)
    worksheet.write(@row_value+5, 11,"REQ SOURCE", header)
    worksheet.write(@row_value+5, 12,"BUS UNIT", header)
    worksheet.write(@row_value+5, 13,"ACTIVITY ID", header)
    worksheet.write(@row_value+5, 14,"DATE / TIME", header)
    worksheet.write(@row_value+5, 15,"SITE CODE", header)
    worksheet.write(@row_value+5, 16,"FILENAME", header)
    worksheet.write(@row_value+5, 17,"CREATED", header)
    worksheet.write(@row_value+5, 18,"TRANSER TYPE", header)
    worksheet.write(@row_value+5, 19,"PAYLOAD ID", header)

    @delivery_file_list.each_with_index do |file, i|
      worksheet.write(@row_value+6+i,0,file["part_no"],format2)
      worksheet.write(@row_value+6+i,1,file["part_type"],format2)
      worksheet.write(@row_value+6+i,2,file["qty"],format2)
      worksheet.write(@row_value+6+i,3,file["uom"],format2)
      worksheet.write(@row_value+6+i,4,file["to_stockroom"],format2)
      worksheet.write(@row_value+6+i,5,file["order_no"],format2)
      worksheet.write(@row_value+6+i,6,file["order_line_no"],format2)
      worksheet.write(@row_value+6+i,7,file["invoice_no"],format2)
      worksheet.write(@row_value+6+i,8,file["bin_line_station"],format2)
      worksheet.write(@row_value+6+i,9,file["order_date"],format2)
      worksheet.write(@row_value+6+i,10,file["delivery_date"],format2)
      worksheet.write(@row_value+6+i,11,file["req_source"],format2)
      worksheet.write(@row_value+6+i,12,file["business_unit"],format2)
      worksheet.write(@row_value+6+i,13,file["activity_id"],format2)
      worksheet.write(@row_value+6+i,14,file["date_time_stamp"],format2)
      worksheet.write(@row_value+6+i,15,file["site_code"],format2)
      worksheet.write(@row_value+6+i,16,file["filename"],format2)
      worksheet.write(@row_value+6+i,17,file["create_date"],format2)
      worksheet.write(@row_value+6+i,18,file["tran_type"],format2)
      worksheet.write(@row_value+6+i,19,file["payload_id"],format2)
    end
    workbook.close
    send_file Rails.public_path+"/excel/boeing_delivery_files/BOEING_DELIVERY_FILE.xls", :disposition => "attachment"

  end

  def search
    redirect_to 'index',:locals => { :search_part_number => params[:search_part_number] }
  end

end