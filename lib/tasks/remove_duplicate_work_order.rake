namespace :remove do
  desc "Remove Duplicate work orders."
  task :work_order => :environment do
    Kitting::WorkOrder.transaction do
      puts "Grouping Records."
      grouped = Kitting::WorkOrder.all.sort.group_by{|model| [model.order_number,model.stage,model.serial_number] } rescue {}
      puts "Executing #{grouped.count} No of Records."
      grouped.values.each do |duplicates|
        # the first one we want to keep right?
        first_one = duplicates.shift # or pop for last one
        # if there are any more left, they are duplicates
        # so delete all of them
        duplicates.each do |double|
          Kitting::KitWorkOrder.find_all_by_work_order_id(double.id).map(&:destroy)
          double.destroy # duplicates can now be destroyed
        end
      end
      puts "Executed sucessfully ."
    end
  end
end