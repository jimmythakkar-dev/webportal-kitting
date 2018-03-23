# spec/factories/kit_media_types.rb
require 'faker'
FactoryGirl.define do
	factory :kit_media_type, class: Kitting::KitMediaType do |f|
		f.name "Test KMT"
		f.compartment 16
		f.kit_type "configurable"
    f.customer_number "029540"
  end

  factory :invalid_kit_media_type, parent: :kit_media_type do |f|
    f.name nil
  end
end
