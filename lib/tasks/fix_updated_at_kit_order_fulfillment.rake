namespace :fix_updated_at_kit_order_fulfillment do
  desc "Update column updated_at for kit order fulfillment table "
  task :update => :environment do
    ActiveRecord::Base.transaction do

      #Update Customer Number for records that have null cust_no.
      @kit_order_fulfillments = Kitting::KitOrderFulfillment.where('cust_no is null')
      if @kit_order_fulfillments.blank?
        puts "There are no customer numbers that need to be updated."
      else
        print "Updating Customer Number for #{@kit_order_fulfillments.count} records ..."
        count = not_count = 0
        @kit_order_fulfillments.each do |kit_order_fulfillment|
          begin
            #Getting Customer Number from kit_fillings and updating it in Order Fulfillment Table
            if kit_order_fulfillment.kit_filling.present?
              cust_no = kit_order_fulfillment.kit_filling.created_by
              if cust_no.blank?
                not_count = not_count + 1
              else
                kit_order_fulfillment.update_attribute(:cust_no, cust_no)
                print "."
                count = count + 1
              end
              #Getting Customer Number from kits table if not record not present in kit_fillings and updating it in Order Fulfillment Table
            else
              kit_number = Kitting::Kit.where(:kit_number => kit_order_fulfillment.kit_number)
              if kit_number.blank?
                not_count = not_count + 1
              else
                cust_no = kit_number.first.cust_no
                kit_order_fulfillment.update_attribute(:cust_no, cust_no) unless cust_no.blank?
                print "."
                count = count + 1
              end
            end
          rescue => e
            not_count = not_count + 1
          end
        end
        puts  "\nCustomer Number for #{count} Records Updated."
        puts  "Customer Number for #{not_count} Records were not updated."
      end

      #Update Updated_at for records which differ from its actual update date.
      @fulfillment_date_entries = Kitting::KitOrderFulfillment.where('TO_CHAR(created_at) != TO_CHAR(updated_at)')
      if @fulfillment_date_entries.blank?
        puts "There are no dates that  need to be updated."
      else
        print "Updating Dates For #{@fulfillment_date_entries.count} records ..."
        count = not_count = 0
        @fulfillment_date_entries.each do |fulfillment_date|
          begin
            if fulfillment_date.created_at.present?
              created_date = fulfillment_date.created_at
              fulfillment_date.update_attribute(:updated_at,created_date)
              print "."
              count = count + 1
            end
          rescue => e
            not_count = not_count + 1
          end
        end
        puts  "\n#{count} Dates Updated."
        puts  "#{not_count} Dates were  not updated."
      end
    end
  end
end