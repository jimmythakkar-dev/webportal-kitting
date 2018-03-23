module Kitting
  module KitFillingHelper
    # user for toggle Water level quantity on kit filling
    def toggle_val qty
      case qty
        when "WL"
          "S"
        when "S"
          "E"
        when "E"
          "WL"
        when "0"
          "S"
        else
          "E"
      end
    end
  end
end
