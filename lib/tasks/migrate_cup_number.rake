namespace :migrate do
	desc "Insert Cup number to Table Kitting:Cup"
	task :cup_number => :environment do
		config.logger.warn "Started Migrating Cup Number."
		Kitting::Cup.transaction do
			kit_ids = Kitting::Cup.all.map(&:kit_id).uniq
			kit_ids.each do |kit_id|
				orig_cup_id = Kitting::Cup.where("kit_id = ? and commit_id IS NULL",kit_id).order("id asc").map(&:id)
				array_for_cup_number = (1..orig_cup_id.count).to_a
				cup_num = Hash[*orig_cup_id.zip(array_for_cup_number).flatten]
				config.logger.warn "{'cup_record' =>  #{cup_num} }"
				orig_cup_id.each { |cup|
					Kitting::Cup.find(cup).update_attribute("cup_number",cup_num[cup])
				}
			end
			dup_cup_id = Kitting::Cup.where("commit_id IS NOT NULL").order("id asc")
			# Transaction to Update UnCommited Cups
			dup_cup_id.each do  |dup_cup|
				dup_cup.update_attribute("cup_number",Kitting::Cup.find(dup_cup.commit_id).cup_number)
			end
		end
	end
end