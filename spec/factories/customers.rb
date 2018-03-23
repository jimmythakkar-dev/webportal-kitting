require 'faker'
FactoryGirl.define do
  factory :customer, class: Kitting::Customer do |f|
    f.cust_no "029540"
    f.cust_name "BOEING PHILADELPHIA 4PL"
    f.user_name "BOEING.PHIL.BE"
    f.user_level "5"
    f.user_type "C"
  end
end
