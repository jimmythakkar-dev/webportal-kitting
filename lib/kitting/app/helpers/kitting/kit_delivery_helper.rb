module Kitting
  module KitDeliveryHelper
    # Method to process delivery codes
    def process_message code, processed_date="N/A"
      case code
        when 1
          "Successfully Processed."
        when 2
          "Delivery ID/Pack ID not recognized."
        when 3
          "Delivery Point not recognized."
        when 4
          "Date/Time Invalid."
        when 5
          "Duplicate (Processed on: #{processed_date})"
        when 6
          "Invalid Format"
        when 7
          "Error updating Delivery data contact KLX Administrator."
        else
          "Invalid Entry"
      end
    end
  end
end