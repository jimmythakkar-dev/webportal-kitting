# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Kitting::Customer.find_or_create_by_cust_no_and_cust_name(cust_no: "SYSTEM", cust_name: "SYSTEM", user_name: "SYSTEM", user_level: "SYSTEM", user_type: "SYSTEM" )
puts "Creating Default Locations if not created already"
["Empty Queue","NEW KIT QUEUE","SOS Queue","Send to Stock","Ship/Invoice","Picking Queue"].each do |location|
     Kitting::Location.find_or_create_by_name(location)
 end
 puts "Creating default Media Types"
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "Binder KMT", :compartment => 1000, :kit_type => "binder",:customer_number => "029540",:compartment_layout => {"1"=>""}.to_json)
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "8 Dividable Small Tub", :compartment => 8, :kit_type => "non-configurable",:customer_number => "029540",:compartment_layout => {"1"=>"1","2"=>"1","3"=>"1","4"=>"1","5"=>"1","6"=>"1","7"=>"1","8"=>"1"}.to_json)
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "16 Dividable Medium Tub", :compartment => 16, :kit_type => "non-configurable",:customer_number => "029540",:compartment_layout => {"1"=>"1","2"=>"1","3"=>"1","4"=>"1","5"=>"1","6"=>"1","7"=>"1","8"=>"1","9"=>"1","10"=>"1","11"=>"1","12"=>"1","13"=>"1","14"=>"1","15"=>"1","16"=>"1"}.to_json)
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "24 Dividable Large Tub", :compartment => 24, :kit_type => "non-configurable",:customer_number => "029540",:compartment_layout => {"1"=>"1","2"=>"1","3"=>"1","4"=>"1","5"=>"1","6"=>"1","7"=>"1","8"=>"1","9"=>"1","10"=>"1","11"=>"1","12"=>"1","13"=>"1","14"=>"1","15"=>"1","16"=>"1","17"=>"1","18"=>"1","19"=>"1","20"=>"1","21"=>"1","22"=>"1","23"=>"1","24"=>"1"}.to_json)
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "8 RTB Tacklebox", :compartment => 8, :kit_type => "non-configurable",:customer_number => "029540",:compartment_layout => {"1"=>"4","2"=>"4"}.to_json)
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "24 RTB Tacklebox", :compartment => 24, :kit_type => "non-configurable",:customer_number => "029540",:compartment_layout => {"1"=>"6","2"=>"6","3"=>"6","4"=>"6"}.to_json)
 Kitting::KitMediaType.find_or_create_by_name(:name => "--",:compartment => 1000, :description => "Binder Type Kit For Cardex Kit.",:kit_type => "binder",:compartment_layout => {"1"=>""}.to_json)
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "Small Removable Cup TB", :compartment => 18, :kit_type => "configurable",:customer_number => "SYSTEM",:compartment_layout => {"1"=>""}.to_json)
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "Large Removable Cup TB", :compartment => 48, :kit_type => "configurable",:customer_number => "SYSTEM",:compartment_layout => {"1"=>""}.to_json)
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "Small Configurable TB", :compartment => 10, :kit_type => "configurable",:customer_number => "SYSTEM",:compartment_layout => {"1"=>""}.to_json)
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "Multiple Media Type", :compartment => 0, :kit_type => "multi-media-type",:customer_number => "SYSTEM",:compartment_layout => {"1"=>""}.to_json)
 Kitting::KitMediaType.find_or_create_by_customer_number_and_name(:name => "Bagged", :compartment => 1000, :description => "Bagged Media Type",:kit_type => "binder",:customer_number => "026565",:compartment_layout => {"1"=>""}.to_json)

customer = Kitting::Customer.find_or_create_by_cust_no_and_cust_name(cust_no: "SYSTEM", cust_name: "SYSTEM")
customer.update_attribute("upload_configuration" , {"Material"=>"Material", "Material Description"=>"Material Description",
                                                    "Bulk Material"=>"Bulk Material", "Order"=>"Order",
                                                    "Stage Material"=>"Material", "WBS element"=>"WBS element",
                                                    "Pegged requirement"=>"Pegged requirement", "Base Unit of Measure"=>"Base Unit of Measure",
                                                    "Requirement Quantity"=>"Requirement Quantity", "Requirement Date"=>"Requirement Date"}.to_json)
puts "Success !"

puts "Seeding data for Delivery Point"

# Seed Delivery Point for Agusta Station # Requirement API-16[Addendum Kit Delivery]
DELIVERY_POINT = "Comp Kit - US01 WH,AW139 Bay 1,AW139 Bay 2,AW139 Bay 3,AW139 Bay 4,AW139 Bay 5,AW139 Bay 6,AW139 Bay 7,AW139 Bay 8,AW119 Bay 1,AW119 Bay 2,AW119 Bay 3,AW119 Bay 4,AW169 Bay 5,AW169 Bay 6,AW169 Bay 7,AW169 Bay 8,AW169 Bay 9,AW169 Bay 10,AW139 FL,AW119 FL,AW169 FL,BUILD-UP,TUNNEL"
DELIVERY_POINT.split(",").each do |delivery_point|
  AgustaStation.find_or_create_by_customer_number_and_station_type_and_name(:name => delivery_point,:station_type => "DELIVERY_POINT", :customer_number => customer.cust_no)
end
