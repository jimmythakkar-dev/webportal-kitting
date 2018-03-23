require 'faker'
FactoryGirl.define do
  factory :kit, class: Kitting::Kit do |f|
  	f.kit_number {Faker::Name.name}
  	f.bincenter {Faker::Name.name}
  	f.kit_media_type_id {Faker::Number.number 3}
  end
end
