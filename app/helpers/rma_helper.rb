module RmaHelper

  # Converts 'mm/dd/yyyy' date format into 'mm/dd/yy' format
  def yyyy_to_yy(date_str)
    split_date = date_str.split("/") if date_str
    date_year = split_date[2].to_i % 100 if split_date[2]
    formatted_date = split_date[0] + "/" + split_date[1] + "/" + date_year.to_s
    formatted_date
  end

  def greater_array_length(arr1, arr2)
    line1 = arr1.length
    line2 = arr2.length
    [line1, line2].max
  end

  def sort_array(closed_cancelled_rma_ids,response_rma)
    array_dates = []
    closed_cancelled_rma_ids.each do |index|
      array_dates << response_rma["issueDates"][index]
    end
    ra, rb = array_dates.zip(closed_cancelled_rma_ids).sort_by{|date| Date.strptime(date.first, "%m/%d/%Y")}.transpose
    return rb
  end

  def check_hpp_part_number(part_number)
    if part_number.present?
      hpp_flag = invoke_webservice method: 'get', action: 'productData',
                                           query_string: { productIn: part_number }
       if hpp_flag
        if hpp_flag["errMsg"].blank?
          if hpp_flag["hppCode"] == "Y"
            return true
          else
            return false
          end
        end
       end
    end
  end
  
end
