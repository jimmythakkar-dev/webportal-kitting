namespace :update_cust_no_order_fulfillment_table do
  desc "Update Cust No for kit_order_fulfillments table which is nil currently "
  task :update => :environment do
    config.logger.warn "Started Updating Cust_No column ."
    puts "Started Updating Cust Nos..."
    ActiveRecord::Base.transaction do
      @kit_order_fulfillments = Kitting::KitOrderFulfillment.where('cust_no is null')
      if @kit_order_fulfillments.blank?
        puts "There are no records that have been updated ."
        config.logger.warn "There are no records that have been updated ."
      else
        print "Updating #{@kit_order_fulfillments.count} records ..."
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
            config.logger.warn "Failed Creating/Updating entries. #{e.backtrace} "
          end
        end
        config.logger.warn "#{count} Records Updated."
        config.logger.warn "#{not_count} Records Updated."
        puts  "\n#{count} Records Updated."
        puts  "#{not_count} Records Unupdated."
      end
    end
  end
end