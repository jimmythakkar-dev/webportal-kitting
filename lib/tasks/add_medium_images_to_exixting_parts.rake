namespace :db do
  namespace :migrate do
    desc "Add Medium size image to exixting parts."
    task :medium_image => :environment do
      puts "Started to Process #{Kitting::Part.where("image_name is not null").count} Parts."
      Kitting::Part.find_each do |part|
        begin
          part.image_name.recreate_versions!(:medium) if part.image_name.present?
        rescue => e
          puts e.backtrace
        end
      end
      puts "Processed Medium Size Images."
    end
  end
end