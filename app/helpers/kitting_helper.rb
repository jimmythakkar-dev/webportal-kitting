module KittingHelper

  def display_status(status)
     if status == '1'
       return "Active"
     elsif status == '2'
       return "Pending"
     elsif status == '6'
       return "Inactive"
     end
  end

end
