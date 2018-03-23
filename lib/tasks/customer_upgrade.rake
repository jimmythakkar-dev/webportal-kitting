namespace :upgrade do
	desc "Remove Duplicate User entries and update it in associated tables."
	task :customer => :environment do
		Rails.logger.info "Starting rake task for Updating Customer Records."
		tables_to_update = [Kitting::Kit,Kitting::KitCopy,Kitting::KitMediaType,Kitting::KitFilling,Kitting::Part]
		count= 0; uname = Array.new
		Kitting::Customer.all.each do |cust|
			count += 1 unless cust.user_name == cust.user_name.upcase.strip
			uname  << "#{cust.id}-#{cust.cust_name}-#{cust.user_name}" unless cust.user_name == cust.user_name.upcase.strip
			cust.update_attribute("user_name",cust.user_name.upcase.strip)
		end
		Rails.logger.info "#{count} records with user_name(s) #{uname.join(",")} is Stripped and Capitalized."
		puts "#{count} records with user_name(s) #{uname.join(",")} is Stripped and Capitalized."
		customer = Kitting::Customer.pluck(:user_name).uniq
		master_record = Hash.new
		customer.each do |cust|
			master_record[cust] = Kitting::Customer.find_by_user_name(cust).id
		end
		master_record.each_pair do |customer,master_id|
			customer_records = Kitting::Customer.where("user_name = ? and id NOT IN ?", customer,master_id)
			customer_records.each do |cust_rec|
				tables_to_update.each do |table|
					Rails.logger.info "Processing #{table} MODEL FOR #{cust_rec.user_name} AND CUSTOMER ID #{cust_rec.id}."
					puts "Processing #{table} MODEL FOR #{cust_rec.user_name} AND CUSTOMER ID #{cust_rec.id}."
					table_data = table.where("customer_id = ?",cust_rec.id)
					Rails.logger.info table_data.inspect
					table_data.each do |data|
						status = data.update_attribute("customer_id",master_id)
						Rails.logger.info "STATUS FOR #{data.inspect} is #{status}"
						puts "STATUS FOR #{data.inspect} is #{status}"
					end
				end
			end
			Rails.logger.info "Starting to Destroy Customer Records"
			Rails.logger.info "#{customer_records.inspect}"
			customer_records.destroy_all
			Rails.logger.info "Destroyed Records."
		end
		Rails.logger.info "Stopping Rake Task for Updating Customer Records."
	end
end