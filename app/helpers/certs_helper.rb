module CertsHelper
  def get_image_details(images, images_full_path)
    @images_array = []
    images.each_with_index do |value, index|
      @images_array << images_full_path[index]+ ".tif"
    end
    return @images_array;
  end
end
