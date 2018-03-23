module AgustaHelper
  # Converts 'mm/dd/yyyy' date format into 'mm/dd/yy' format
  def yyyy_to_yy(date_str)
    split_date = date_str.split("/") if date_str
    date_year = split_date[2] if split_date[2]
    formatted_date = split_date[0] + "/" + split_date[1] + "/" + date_year.to_s
  end
end