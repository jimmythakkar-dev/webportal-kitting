# spec/factories/locations.rb
require 'faker'
FactoryGirl.define do
	factory :location, class: Kitting::Location do |f|
		f.name "Test Location"
	end
  factory :invalid_location, parent: :location do |f|
    f.name nil
  end
end
