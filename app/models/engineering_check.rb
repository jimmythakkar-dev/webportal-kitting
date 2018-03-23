class EngineeringCheck

  # divide_records_in_pages, per page 100 records

  def self.divide_records_in_pages total_records
    total_page =  total_records/100
    if total_records/100 < 1
      total_page = 1
    else
      if total_records % 100 == 0
        total_page = total_records/100
      else
        total_page = (total_records/100) + 1
      end
    end
  end

  # extract month and year from the data comming from RBO
  def self.extract_month_and_year dates
    dates.collect! do |date|
      date_splitter = date.split("/")
      date_splitter.first + "/" + date_splitter.last
    end
  end

  #convert array to string
  def self.get_covert_arr_to_str(arr_responce)
    if arr_responce.kind_of? Array
      arr_responce= arr_responce.join()
    else
      arr_responce= arr_responce
    end
  end

  # create ship list data in array for display in shipment tabel
  def self.get_order_ship_date_list orders, quantity
    shipped_array = []
    unless orders.blank?
      orders.each_index do |main_index|
        for index in 0..35
          my_date = Time.now.months_since(-13 + (index + 1)).strftime('%m/%y')
          if orders[main_index] == my_date
            shipped_array[index] = shipped_array[index].to_i + quantity[main_index].to_i
          else
            shipped_array[index] =  shipped_array[index].to_i + 0
          end
        end
      end
    else
      shipped_array = Array.new(36,'0')
    end
    shipped_array
  end
  # create forcast list data in array for display in shipment tabel
  def self.get_forecast_with_archive (qtyList_arch, periods_arch, qtyList, periods, my_date)
    my_fc_array = Array.new(36,'-')
    unless qtyList_arch.join().blank?
      my_date.each_index do |main_index|
        qtyList_arch.each_index do |index|
          if periods_arch[index] == my_date[main_index]
            my_fc_array[main_index] = qtyList_arch[index]
          end
        end
      end
    end
    unless qtyList.join().blank?
      my_date.each_index do |main_index|
        qtyList.each_index do |index|
          if periods[index] == my_date[main_index]
            my_fc_array[main_index] = qtyList[index]
          end
        end
      end
    end
    my_fc_array
  end

  # select time period for engineering check
  def self.get_dates
    dates_KB7 = []
    for index in 0..35
      dates_KB7[index]  = Time.now.months_since(-13 + (index + 1)).strftime("%m/01/%y")
    end
    dates_KB7
  end

  #convert string to array
  def self.get_convert_to_array bin_parts_response
    bin_parts_response.join(",").split(",")
  end
end
