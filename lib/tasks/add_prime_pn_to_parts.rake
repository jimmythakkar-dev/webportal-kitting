namespace :db do
  namespace :migrate do
    desc "Add Prime Part Number to Parts Table # PC-58 "
    task :prime_pn => :environment do
      include ApplicationHelper
      time = Time.now
      customer_number = "029540"
      display_msg "Starting Migration for adding Prime Part number to Parts Table in #{Rails.env} environment at (#{time}) ...\n"
      parts_with_image = Kitting::Part.all
      puts parts_with_image.map(&:part_number)
      parts_with_image.each_with_index do |part,index|
        @response = invoke_service method: 'get', class: 'custInv/',action:'partNums', query_string: { custNo: customer_number, partNo: part.part_number.upcase }
        if @response && @response["errMsg"].present? && @response["errCode"].present?
          display_msg("#{index}. Error While Invoking Mule Webservice for part #{part.part_number} with id #{part.id} is #{@response["errMsg"]} ")
        else
          if @response
            display_msg("#{index}. Prime PN for Part #{part.part_number} with id #{part.id} is #{@response["primePNList"]} .")
            if @response["primePNList"].reject(&:blank?).empty?
              display_msg("\t EMPTY PRIME PN AFTER REJECTING BLANK VALUE FOR PART NUMBER #{part.part_number} with id #{part.id} .")
            else
              if part.update_attribute("prime_pn",@response["primePNList"].reject(&:blank?).first)
                display_msg("\t Part Update Successfully with Validated Prime PN")
              else
                display_msg("\t Unable to Update PRIME PN for Part #{part.part_number} with id #{part.id}")
              end
            end
          else
            display_msg("#{index}. Nil value returned While Invoking Mule Webservice for part #{part.part_number} with id #{part.id} ")
          end
        end
      end
      display_msg "\n Data Migration for adding Prime Part number to Parts Table in #{Rails.env} environment executed Successfully at #{Time.now} ."
    end
  end

  namespace :compute do
    desc "Calculate Parts without PrimePN # PC-58."
    task :parts_without_prime_pn => :environment do
      include ApplicationHelper
      time = Time.now
      customer_number = "029540"
      display_msg "\n Calculating Parts without PrimePN in #{Rails.env} environment at (#{time}) ...\n"
      parts_without_prime_pn = Kitting::Part.where("PRIME_PN IS NULL")
      display_msg "There are #{parts_without_prime_pn.count} Parts without Prime PN, Below is the list:\n"
      parts_without_prime_pn.each_with_index do |part,index|
        display_msg("#{index} Part ID: #{part.id} - Part Number: #{part.part_number} .")
      end
      display_msg "\n Prime Part number Computation on  Parts Table in #{Rails.env} environment executed Successfully at #{Time.now} ."
    end
  end

  def display_msg(msg)
    File.open(File.join(Rails.root, "doc","parts_status.docx"),"a+") do |f|
      f.write(msg)
      f.write("\n")
    end
    puts msg
  end
end