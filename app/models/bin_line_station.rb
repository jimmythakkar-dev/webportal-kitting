# This model file mainly contains methods used BinLineStationController class,
# the methods define here can also be used in other controllers as well.
class BinLineStation
  def self.get_error_message error_message, part_number
    if error_message.include? "not on bin map; Please use panstock to order."
      error_message.gsub(/#{part_number.try(:upcase)} not on bin map; Please
        use panstock to order./, "#{part_number.try(:upcase)} not on bin map.")
    elsif error_message.include? "|"
      error_message.gsub(/|/, "")
    else
      error_message
    end
  end

  def self.get_customer_values response, part_number
    get_values = {}

    if response["custPartNoList"].blank?
      @response_part_no_list = [""]
    else
      @response_part_no_list = response["custPartNoList"].join("").gsub(/[^0-9a-z ]/i, '')
    end

    if response["ref"].blank?
      response["ref"] = [""]
    end
    if response["scancodeList"].blank?
      response["scancodeList"] = [""]
    end
    if response["invPNList"].blank?
      response["invPNList"] = [""]
    end
    if response["primePNList"].blank?
      response["primePNList"] = [""]
    end

    @part_number = part_number.gsub(/[^0-9a-z ]/i, '')
    #if ((response["custPartNoList"].include? part_number) || (response["ref"].include? part_number))
    if ((@response_part_no_list.include? @part_number) || (response["ref"].include? part_number))
      get_values[:customer_ref_number] = part_number
      get_values[:contract_part_number] = response["invPNList"].first
      get_values[:ship_to] = response["ShipTo"]
      get_values[:prime_part_number] = response["primePNList"].first
      get_values
    elsif response["invPNList"].include? part_number
      part_number_index = response["invPNList"].index part_number
      get_values[:customer_ref_number] = response["ref"][part_number_index]
      get_values[:contract_part_number] = response["invPNList"][part_number_index]
      get_values[:prime_part_number] = response["primePNList"].first
      get_values
    elsif response["primePNList"].include? part_number
      part_number_index = response["primePNList"].index part_number
      get_values[:customer_ref_number] = response["ref"][part_number_index]
      get_values[:contract_part_number] = response["invPNList"][part_number_index]
      get_values[:prime_part_number] = response["primePNList"].first
      get_values
    elsif response["scancodeList"].include? part_number
      part_number_index = response["scancodeList"].index part_number
      get_values[:customer_ref_number] = response["ref"][part_number_index]
      get_values[:contract_part_number] = response["invPNList"][part_number_index]
      get_values[:prime_part_number] = response["primePNList"].first
      get_values
    else
      "#{part_number.try(:upcase)} not on Bin Map or Contract.
          Please contact your KLX representative."
    end


  end

  def self.set_order_quantity bin_map
    bin_map && bin_map["orderQty"].empty? ?  [] : bin_map["orderQty"].first.split(",")
  end

  def self.set_order_date bin_map
    bin_map && bin_map["orderDt"].empty? ?  [] : bin_map["orderDt"].split(",")
  end

  def self.excel_path
    current_time = Time.now.strftime("%m/%d/%Y %H:%M:%S")
    p "#{Rails.public_path}/excel/bin_line_station/bin_list_out_#{current_time}.xls"
  end
end