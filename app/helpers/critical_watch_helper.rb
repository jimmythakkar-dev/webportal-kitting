module CriticalWatchHelper

  def select_filter(arry,building,open_close)
    filter_array = []
    case building
    when "SAT"
      if open_close == "CL"
       if arry["building"] == "Satellite Buildings" && arry["updateItemStatus"].last == "Closed"
         filter_array = arry
       end
      elsif open_close == "" || open_close == nil
        if arry["building"] == "Satellite Buildings" && arry["updateItemStatus"].last != "Closed"
          filter_array = arry
        end
      elsif open_close == "ALL"
        if arry["building"] == "Satellite Buildings" && arry["updateItemStatus"]
          filter_array = arry
        end
      end
      filter_array
    when "B67"
      if open_close == "CL"
       if arry["building"] == "B-67" && arry["updateItemStatus"].last == "Closed"
         filter_array = arry
       end
      elsif open_close == "" || open_close == nil
        if arry["building"] == "B-67" && arry["updateItemStatus"].last != "Closed"
          filter_array = arry
        end
      elsif open_close == "ALL"
        if arry["building"] == "B-67" && arry["updateItemStatus"]
          filter_array = arry
        end
      end
      filter_array
    when "B101"
      if open_close == "CL"
       if arry["building"] == "B-101" && arry["updateItemStatus"].last == "Closed"
         filter_array = arry
       end
      elsif open_close == "" || open_close == nil
        if arry["building"] == "B-101" && arry["updateItemStatus"].last != "Closed"
          filter_array = arry
        end
      elsif open_close == "ALL"
        if arry["building"] == "B-101" && arry["updateItemStatus"]
          filter_array = arry
        end
      end
      filter_array
    else
      if open_close == "CL"
       if arry["building"] && arry["updateItemStatus"].last == "Closed"
         filter_array = arry
       end
      elsif open_close == "" || open_close == nil
        if arry["building"] && arry["updateItemStatus"].last != "Closed"
          filter_array = arry
        end
      elsif open_close == "ALL"
        if arry["building"] && arry["updateItemStatus"]
          filter_array = arry
        end
      end
      filter_array
    end
  end

  def date_format
    Time.now.strftime("%m/%d/%Y")
  end

end
