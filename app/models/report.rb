class Report < ActiveRecord::Base
  attr_accessible :cust_no, :description, :name, :file_name,:uploaded_by

  validates :file_name, :presence => {:message => 'File Name cannot be blank, Task not saved'}
  validates :cust_no, :presence => {:message => 'Customer Number cannot be blank, Task not saved'}
  mount_uploader :file_name, FileNameUploader
  ##
    # Extracting report name from file name
    # Appending current user to report name
  ##
  def self.get_file_name(report, current_user)
    case report
      when "binmap"
        @file_name = current_user + "_BinMap.xls"
      when "consig"
        @file_name = current_user + "_ConsignInvRpt.xls"
      when "onhand"
        @file_name = current_user + "_onHandRpt.xls"
      when "openor"
        @file_name = current_user + "_OpenOrdersRpt.xls"
      when "emptie"
        @file_name = current_user + "_EmptiesRpt.xls"
      when "binact"
        @file_name = current_user + "_BinActivityRpt.xls"
      when "custfo"
        @file_name = current_user + "_CustForecastRpt.xls"
      when "pastdu"
        @file_name = current_user + "_PastDueRpt.xls"
      when "qclab"
        @file_name = current_user + "_QCLabTracking.xls"
      when "deskrequestrpt"
        @file_name = current_user + "_DESK.REQUEST.RPT.xls"
      when "weeklykitrpt"
        @file_name = current_user + "_wkly_kit.xls"
    end
  end

  ##
    # Checking directory exists in specified path
    # Returns true or false
  ##
  def self.directory_exists?(directory)
    File.directory?(directory)
  end

  ##
    # Checking directory exists in specified directory
    # Returns true or false
  ##
  def self.file_exists?(directory)
    File.exist?(directory)
  end
end
