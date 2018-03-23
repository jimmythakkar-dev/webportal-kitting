require 'faker'
FactoryGirl.define do
  factory :cup, class: Kitting::Cup do |f|
    f.kit_id {Faker::Number.number 3}
  end
end
