class AddColumnUploadConfigurationToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :upload_configuration, :text
  end
end
