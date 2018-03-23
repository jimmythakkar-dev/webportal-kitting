namespace :migrate do
	desc "Migrate KIT BOM BULK OPERATIONS from Kit Uploads."
	task :bom_operations => :environment do
		kit_uploads = Kitting::KitUpload.where("is_bom_download = ?",false)
		print "STARTED MIGRATING RECORDS FROM KIT UPLOADS TO KIT BOM BULK TRANSACTIONS "
		count = 0
		kit_uploads.each do |data|
			print "."
			 if data.file_path.nil?
				path = "#{data.old_part_number}_#{data.new_part_number}_#{data.id}.csv".gsub("/","-")  rescue "Response_#{data.id}.csv"
				op_type= "PART REPLACEMENT"
			 else
				 path = data.file_path
				 op_type = "KIT UPLOAD"
			 end
			operation = Kitting::KitBomBulkOperation.new
			#operation.id = data.id
			operation.operation_type= op_type
			operation.file_path= path
			operation.status= data.status
			operation.customer_id= data.customer_id
			operation.new_part_number= data.new_part_number
			operation.old_part_number= data.old_part_number
			operation.is_downloaded= data.download_status
			operation.created_at= data.created_at
			operation.updated_at= data.updated_at
			if operation.save
			 config.logger.warn "RESULT SET FOR #{data.inspect} is #{operation.inspect}"
			count += 1
			else
				config.logger.warn "ERROR MIGRATING DATA FOR #{data.inspect} =>  #{operation.inspect} "
			end
		end
		puts " "
		puts "MIGRATION PROCESS SUCCEEDED WITH #{count} Record(s)."
	end
end