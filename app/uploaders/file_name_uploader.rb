# encoding: utf-8

class FileNameUploader < CarrierWave::Uploader::Base
  storage :file
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    #"uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    # Image store in path given in part_image_path from config file and create folder of image id
    "#{APP_CONFIG['shared_folder_path']}"
  end

  def extension_white_list
    %w(xls xlsx doc docx)
  end

  def filename
    "#{model.cust_no}_" + super
  end
end