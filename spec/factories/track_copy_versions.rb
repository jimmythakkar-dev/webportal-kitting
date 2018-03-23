# spec/factories/track_copy_versions.rb
require 'faker'
FactoryGirl.define do
	factory :track_copy_version, class: Kitting::TrackCopyVersion do |f|
		f.kit_copy_id 10025
    f.version "1"
	end
end
