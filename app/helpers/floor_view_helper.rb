module FloorViewHelper

   def get_convert_to_array(bin_part_response)
    bin_part_response.join(",").split(",")
  end

end
