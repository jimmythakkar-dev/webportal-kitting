# spec/factories/cup_parts.rb
require 'faker'
FactoryGirl.define do
	factory :cup_part, class: Kitting::CupPart do |f|
		f.cup_id 22519
    f.part_id 10003
    f.demand_quantity "12"
	end
#  factory :invalid_location, parent: :location do |f|
#    f.name nil
#  end
end
