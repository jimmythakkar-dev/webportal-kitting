namespace :remove_existing_certificates do
  desc "Remove Existing Certificates from public directory"
  task :delete => :environment do
    @public_certificate_path = File.expand_path("#{Rails.root}/public/certificates")
    if File.directory?(@public_certificate_path)
      @files = Dir.glob(@public_certificate_path + '/*')
      puts "Removing Certificates ...."
      if @files.blank?
        puts "No certificate files to remove."
        Rails.logger.error ".......... No certificate files to remove................\n"
      else
        FileUtils.rm_rf("#{@public_certificate_path}/.", secure: true)
        puts "Deleted Certificate files successfully."
        Rails.logger.error ".................Certificates Removed Successfully..................\n"
      end
    else
      puts "No certificate files to remove."
      Rails.logger.error ".......... No certificate files to remove................\n"
    end
  end
end