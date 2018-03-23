# spec/factories/kit_bom_bulk_operations.rb
require 'faker'
FactoryGirl.define do
	factory :kit_bom_bulk_operation, class: Kitting::KitBomBulkOperation do |f|
		f.file_path "Test.csv"
	end
end
