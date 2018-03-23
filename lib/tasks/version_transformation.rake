namespace :version do
	desc "TRANSFORMATION OF KIT VERSIONS FROM RUBY OBJECTS TO JSON FOR MIGRATION"
	task :update => :environment do
		require "kitting/kit"
		require "kitting/cup"
		require "kitting/cup_part"
		@count = 0
		Kitting::KitVersionTrack.all.each do |record|
				@kit= record.kit
				@cups= record.cups
				@cup_parts = record.cup_parts
				@kit_data = Marshal.load(@kit) rescue "InCompatible DataType"
				@cup_data = Marshal.load(@cups)  rescue "InCompatible DataType"
				@cup_part_data = Marshal.load(@cup_parts) rescue "InCompatible DataType"

			if @kit_data != "InCompatible DataType"
				@status =record.update_attributes(:kit => @kit_data.to_json,:cups => @cup_data.to_json,:cup_parts => @cup_part_data.to_json )
			  @count += 1 if @status
			end
		end
		puts "#{@count} no of records Updated Successfully."
	end
end