class OrderPartDetail < ActiveRecord::Base
  attr_accessible :order_id, :part_number,:quantity,:reason_code,:note,:fulfilment_date_time,:shipment_date_time,:carrier_name,:uom,:filled_state,:cancellation_date,:kit_filling_detail_id, :bin_location, :location_id, :pack_id, :received_flag,:delivery_point,:delivery_date,:delivered
  has_paper_trail
  belongs_to :order
  belongs_to :kit_filling_detail, :class_name => "Kitting::KitFillingDetail"
  belongs_to :location, :class_name => "Kitting::Location"
  after_create :add_details

  def self.get_cancellation_date
    get_cancellation_values = [["Select Date",""],["Today",0], ["Next 2 Days",2], ["Next 3 Days",3],
                               ["Next 5 Days",5], ["This Week",7], ["Next 2 Weeks",14],
                               ["Next 1 Month",30], ["Next 2 Months",60], ["Next 3 Months",90],
                               ["Next 4 Months",120], ["Next 5 Months",150],
                               ["Next 6 Months",180], ["Next 8 Months",240], ["Next Year",365]]
  end

  def add_details
    if self.order.order_type == "CRIB"
      self.update_attribute("pack_id","CP-#{self.id}")
      self.update_attribute("location_id",Kitting::Location.find_by_name("NEW KIT QUEUE").id)
      self.update_attribute("filled_state","E")
    end
  end
end