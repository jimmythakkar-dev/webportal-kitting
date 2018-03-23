if LogStasher.enabled
	LogStasher.add_custom_fields do |fields|
		fields[:customer] = current_customer
		fields[:site] = request.path
		fields[:company] =current_company
		fields[:current_user] = current_user
		# If you are using custom instrumentation, just add it to logstasher custom fields
		LogStasher.custom_fields << :cust_details
	end
end