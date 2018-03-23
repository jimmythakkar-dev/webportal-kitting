require 'active_record'
class RemoteDB < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "remote_db"
end