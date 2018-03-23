=begin
Author: Santosh kumar Mohanty
Date: Sat, 03 May 2014 12:36:11 +0530
Desc: Upload Part Cup Count Records using Upload Process from GUI(CSV Formats only Allowed)
=end
require "csv"
namespace :upgrade do
  desc "Upgrade Cup Count of Part Numbers through Upload Process"
  task :cup_count => :environment do
    include ApplicationHelper
    Rails.logger.error "STARTED CUP COUNT UPGRADATION"
    export_directory= APP_CONFIG["csv_export_path"]
    import_directory = APP_CONFIG["csv_import_path"]
    bulk_operations = Kitting::KitBomBulkOperation.where(:operation_type => "PART CUP COUNT",:status => "UPLOADED")
    bulk_operations.each do |record|
      record.update_attribute("status","PROCESSING")
      export_path="Response_#{record.id}_cup_count_#{record.file_path.gsub(".csv","")}.csv"
      export_file = File.new(File.join(export_directory,export_path),"wb")
      import_file = File.join(import_directory,record.file_path)
      if File.exists?(import_file)
        # OPEN A NEW CSV FILE AND WRITE THE RESULT SET
        CSV.open(export_file, "wb") do |csv|
          begin
            csv << ["PART NUMBER", "LARGE CUP COUNT", "MEDIUM CUP COUNT", "SMALL CUP COUNT"]
            CSV.foreach(import_file,:headers => true,:skip_blanks=> true) do |row|
              if row.headers.length == 4
                # Check For Comment In row
                if row.to_s.strip.scan(/^#/).empty?
                  if row.fields.include?(nil)
                    csv << row.to_csv.gsub("\n","").split(",").push("  #=> INVALID DATA(NIL VALUE NOT ALLOWED)")
                    # Logic if headers include nil value e.g I/p AND-E,54,,55
                  else
                    # Check if Values entered are Numeric
                    if row.fields.last(3).map(&:numeric?).include?(false)
                      csv << row.to_csv.gsub("\n","").split(",").push("  #=> INVALID DATA(ONLY NUMERIC VALUES ALLOWED)")
                      #   Logic if Values are not Numeric
                    else
                      # Logic to Check if fields are positive
                      if row.fields.last(3).map(&:to_i).map(&:positive?).include?(false)
                        csv << row.to_csv.gsub("\n","").split(",").push("  #=> INVALID DATA(ONLY NUMERIC VALUES WITH POSITIVE OR ZERO VALUE ALLOWED)")
                        # Logic to write if a value entered is negative
                      else
                        #  LOGIC TO VALIDATE PART NUMBER
                        params = row.to_hash
                        part_record = Kitting::Part.find_by_part_number_and_customer_number(params["PART NUMBER"].upcase,nil)
                        if part_record.present?
                          if part_record.update_attributes(:large_cup_count => params["LARGE CUP COUNT"],:medium_cup_count => params["MEDIUM CUP COUNT"],:small_cup_count => params["SMALL CUP COUNT"])
                            csv << row.to_csv.gsub("\n","").split(",").push("  #=> SUCCESS RECORD UPDATED")
                            #   LOGIC TO ADD SUCCESS RESULT TO FILE
                          else
                            error = part_record.errors.messages.values.join("&") rescue "Error while Updating PART NUMBER"
                            csv << row.to_csv.gsub("\n","").split(",").push("  #=> ERROR: #{error}")
                            #   Logic if Part update Fails with Error
                          end
                        else
                          response = invoke_service method: 'get', class: 'custInv/',action:'partNums', query_string: { custNo: record.customer.cust_no, partNo: params["PART NUMBER"].upcase }
                          if response["errMsg"] == "" and response["custPartNoList"].include?(params["PART NUMBER"].upcase)
                            new_part = Kitting::Part.new(:name => response["partName"],:part_number => params["PART NUMBER"],:large_cup_count => params["LARGE CUP COUNT"],:medium_cup_count => params["MEDIUM CUP COUNT"],:small_cup_count => params["SMALL CUP COUNT"])
                            if new_part.save
                              csv << row.to_csv.gsub("\n","").split(",").push("  #=> SUCCESS RECORD CREATED AND UPDATED ")
                              #   LOGIC TO ADD SUCCESS RESULT TO FILE
                            else
                              error = new_part.errors.messages.values.join("&") rescue "Error while Updating PART NUMBER"
                              csv << row.to_csv.gsub("\n","").split(",").push("  #=> ERROR: #{error}")
                              #   LOGIC TO ADD IF NEW PART IS NOT CREATED
                            end
                          else
                            #  Logic For INVALID PART MSG like "Part number not found. Please contact your KLX representative."
                            error = response["errMsg"] == "" ? "INVALID PART NUMBER" : response["errMsg"]
                            csv << row.to_csv.gsub("\n","").split(",").push("  #=> ERROR: #{error}")
                          end
                        end
                      end
                    end
                  end
                else
                  # Add Back the Comments
                  csv << row.to_csv.gsub("\n","").split(",")
                end
              else
                csv << row.to_csv.gsub("\n","").split(",").push("  #=> INVALID DATA(I/P HEADERS/VALUES EXCEED LIMIT)")
                # Logic if Headers length is greater than 4 e.g i/p AND-E,45,766,87,90
              end
            end
            record.update_attribute("status","COMPLETED")
          rescue => exception
            FileUtils.rm_rf export_file
            record.update_attribute("status","FAILED")
            Rails.logger.error "ERROR OCCURED WHILE PROCESSING PART COUNT"
            Rails.logger.error exception
          end
        end
      else
        record.update_attribute("status","FAILED")
      end
    end
  end
end