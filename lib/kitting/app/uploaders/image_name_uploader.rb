# encoding: utf-8

class ImageNameUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    #"uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    # Image store in path given in part_image_path from config file and create folder of image id
    "#{APP_CONFIG['part_image_path']}/#{model.id}"
  end

  def url(options = {})
    link = super
    if link.blank?
       prime_pn = model.prime_pn
       if prime_pn.present? &&  Kitting::Part.where("prime_pn = ? and image_name IS NOT NULL",prime_pn).present?
         return prime_part_rec = Kitting::Part.where("prime_pn = ? and image_name IS NOT NULL",prime_pn).first.image_name_url
       else
         return "#{Rails.root}/public/image_not_available.jpg"
       end
    else
      return link
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  process :resize_to_fit => [800, 800]
  # Create different versions of your uploaded files:
  version :thumb do
    #process :scale => [50, 50]
    process :resize_to_limit => [50, 50]
  end

  version :medium do
    #process :scale => [50, 50]
    process :resize_to_limit => [200, 200]
  end

  version :small do
    #process :scale => [50, 50]
    process :resize_to_limit => [100, 100]
  end
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
