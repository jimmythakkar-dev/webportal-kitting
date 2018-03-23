module BinLineStationHelper
  def part_number_exists_in_bin? reference, customer_reference_number
    if reference.first.include? customer_reference_number
      customer_reference_number
    else
      "NO PN FOUND"
    end
  end
end