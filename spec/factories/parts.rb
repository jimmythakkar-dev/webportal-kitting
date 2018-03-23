require 'faker'
FactoryGirl.define do
  factory :part, class: Kitting::Part do |f|
    f.part_number {Faker::Name.name}
  end
end
