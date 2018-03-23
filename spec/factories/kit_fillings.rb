require 'faker'
FactoryGirl.define do
  factory :kit_filling, class: Kitting::KitFilling do |f|
    f.kit_copy_id {Faker::Number.number 3}
  end
end
