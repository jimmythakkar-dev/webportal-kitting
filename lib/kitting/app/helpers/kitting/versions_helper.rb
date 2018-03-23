module Kitting
  module VersionsHelper
    def get_cup_number cup_part
      cup_number = 0
      cup_part.try(:cup).try(:kit).try(:cups).each_with_index do |cup, index|
        if cup.id == cup_part.cup_id
          cup_number = index + 1
          break
        end
      end
      cup_number
    end

    def get_filled_status_name filled_state
      if filled_state == 0
        "Empty"
      elsif filled_state == 1
        "Full"
      else
        "Partial"
      end
    end

    def get_flag_status  flag
      if flag.nil? || flag == true
        "Not Shipped"
      else
        "Shipped"
      end
    end
  end
end