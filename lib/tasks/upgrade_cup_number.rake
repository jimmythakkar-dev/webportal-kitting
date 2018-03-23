namespace :upgrade do
  desc "Upgrade Nill Status Of Cup Records !!!"
  task :cup_status => :environment do
    config.logger.warn "Started Upgrading Cup Status."
    print "Started Upgrading Cup Status."
    Kitting::Cup.transaction do
      cups = Kitting::Cup.where("STATUS IS NULL")
      count = 0
      cups.each do |cup|
        print "."
        config.logger.warn "\t Started Upgrading Cup #{cup.inspect} "
        if cup.status.nil?
          cup.update_attribute("status",true)
          count += 1
        end
      end
      puts "."
      puts "Upgraded #{count} Cup(s). "
      config.logger.warn "Upgraded #{count} Cup(s). "
    end
  end
end
