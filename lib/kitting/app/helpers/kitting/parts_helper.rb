module Kitting
  module PartsHelper
    def customer_part_number(index,part_list)
      if index.present?
        cust_pn = part_list[index]
        if cust_pn.present?
          return cust_pn
        else
          return nil
        end
      else
        return nil
      end
    end
  end
end