# This model file mainly contains methods used Critical Watch class,
# the methods define here can also be used in other controllers as well.
class CriticalWatch
  ##
    # Preparing selId from part number
  ##
  def self.get_sel_id part_number
    if part_number.include? "@"
      sel_id = part_number.gsub("@","/")
      sel_id
    else
      sel_id = part_number
      sel_id
    end
  end

  ##
    # Preparing select box values for Initial Status
    # Including Impact, Delivered, Updated etc
    # Default to Impact
  ##
  def self.get_initial_status_values
    initial_status_values = [[I18n.translate("impact",:scope => "critical_watch.new"), "Impact"],[I18n.translate("delivered",:scope => "critical_watch.new"),"Delivered"],
                             [I18n.translate("updated",:scope => "critical_watch.new"),"Updated"],[I18n.translate("new_add",:scope => "critical_watch.new"),"NewAdd"],
                             [I18n.translate("closed",:scope => "critical_watch.new"),"Closed"]]
    initial_status_values
  end

  ##
    # Preparing select box values for Status
    # Including Critical, Watch, Empty etc
  ##
  def self.get_status_values
    status_values = [[I18n.translate("select",:scope => "critical_watch.index"), "Select"],[I18n.translate("critical",:scope => "critical_watch.new"), "Critical"],
                     [I18n.translate("watch",:scope => "critical_watch.new"), "Watch"],[I18n.translate("empty",:scope => "critical_watch.new"), "Empty"],
                     [I18n.translate("shipped",:scope => "critical_watch.new"), "Shipped"],[I18n.translate("closed",:scope => "critical_watch.new"), "Closed"]]
    status_values
  end

  ##
    # Preparing select box values for Line Responsible
    # Including KLX Aerospace, Partner Suppliers, Customer
  ##
  def self.get_line_resp_values
    line_resp_values = [["Select","Select"],["KLX Aerospace","KLX Aerospace"],
                        [I18n.translate("partner_suppliers",:scope => "critical_watch.new"),"Partner Suppliers"],
                        [I18n.translate("customer",:scope => "critical_watch.new"),"Customer"]]
    line_resp_values
  end

  ##
    # Preparing select box values for Building
    # Including Satellite Buildings, B-67, B-101
  ##
  def self.get_building_values
    building_values = [[I18n.translate("select",:scope => "critical_watch.index"), "Select"],
                        ["Satellite Buildings","Satellite Buildings"],
                        ["B-67","B-67"],["B-101","B-101"]]
    building_values
  end

  ##
    # Preparing select box values for Location and Program
    # Default to Select
    # When Building value is selected, these both select box(Location and Program) values will get populated through js
  ##
  def self.get_location_program_values
    location_program_values = [["Select","Select"]]
    location_program_values
  end

  ##
    # Preparing select box values for Building for index action
    # Including Satellite Buildings, B-67, B-101
  ##
  def self.get_building_list
    building_lists = [[I18n.translate("All Buildings",:scope => "critical_watch.index"), ""],
                       [I18n.translate("Satellite Buildings",:scope => "critical_watch.index"),"SAT"],
                       ["B-67","B67"],["B-101","B101"]]
    building_lists
  end

  ##
    # Preparing select box values for Show for index action
    # Including Open Only, Closed Only, ALL
    # Default to Open Only
  ##
  def self.get_show_list
    show_lists = [[I18n.translate("Open Only",:scope => "critical_watch.index"),""],[I18n.translate("Closed Only",:scope => "critical_watch.index"),"CL"],[I18n.translate("ALL",:scope => "critical_watch.index"),"ALL"]]
    show_lists
  end
end