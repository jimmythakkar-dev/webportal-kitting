every :day, :at => '12:00am' do
   command "rm -rf #{path}/public/barcodes/*"
end

 every :day, :at => '12:00am' do
   command "rm -rf #{path}/private/certificates/*"
 end
every 10.minutes do
  rake "upgrade:cup_count"
end