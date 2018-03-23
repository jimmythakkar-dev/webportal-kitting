class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.string :cust_no
      t.string :description
      t.string :file_name
      t.string :uploaded_by
      t.timestamps
    end
  end
end
