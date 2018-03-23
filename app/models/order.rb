class Order < ActiveRecord::Base
  attr_accessible :order_number, :order_type, :order_status,:customer_name,:customer_number,:project_id,:station_name,:discharge_point_name,:kit_part_number,:remark,:created_by,:updated_by,:due_date,:kit_filling_id,:cancellation_date,:auto_cancelled,:order_part_details_attributes
  has_many :order_part_details, :dependent => :destroy
  has_one :kit_fillings
  has_paper_trail
  accepts_nested_attributes_for :order_part_details, :reject_if => lambda { |a| a[:quantity].blank? || !(a[:quantity].to_f > 0) }, :allow_destroy => true
  validates :order_number, presence: { :message => 'Order Number cannot be blank' } 
  validates :order_type, presence: {  :message => 'Order Type cannot be blank' } 
  validates :customer_name, presence: {  :message => 'Customer Name cannot be blank' }
  validates :customer_number, presence: {  :message => 'Customer Number cannot be blank' }
  validates :project_id, presence: {  :message => 'Aircraft ID cannot be blank' }
  validates :station_name, presence: {  :message => 'Station Name cannot be blank' }
  validates :discharge_point_name, presence: {  :message => 'Discharge Point cannot be blank' }
  validates :kit_part_number, presence: {  :message => 'KPN cannot be blank' }
  validates :created_by, presence: {  :message => 'created_by cannot be blank' }

  after_create :add_kit_part_number
  # Creates  HTML select box from listed date range for Inquiry Search
  def self.date_range
    select_tag_values = [[I18n.translate("today",:scope => "open_orders.index"),"1"], ["2 #{I18n.translate("days",:scope => "open_orders.index")}","2"], ["3 #{I18n.translate("days",:scope => "open_orders.index")}","3"],
                         ["5 #{I18n.translate("days",:scope => "open_orders.index")}","5"], ["1 #{I18n.translate("week",:scope => "open_orders.index")}","7"], ["2 #{I18n.translate("weeks",:scope => "open_orders.index")}","14"],
                         ["1 #{I18n.translate("month",:scope => "open_orders.index")}","30"], ["2 #{I18n.translate("months",:scope => "open_orders.index")}","60"], ["3 #{I18n.translate("months",:scope => "open_orders.index")}","90"],
                         ["4 #{I18n.translate("months",:scope => "open_orders.index")}","120"], ["5 #{I18n.translate("months",:scope => "open_orders.index")}","150"],
                         ["6 #{I18n.translate("months",:scope => "open_orders.index")}","180"], ["8 #{I18n.translate("months",:scope => "open_orders.index")}","240"], [I18n.translate("year",:scope => "open_orders.index"),"365"]]
  end

  # Lists Agusta Search Code for Inquiry Search
  def self.search_code
    select_tag_values = [[I18n.t("select_code",:scope=> "agusta.agusta_inquiry"),nil],[I18n.t("kit_part_number",:scope=> "agusta.agusta_inquiry"),"1"],[I18n.t("part_number",:scope=> "agusta.agusta_inquiry"),"2"],[I18n.t("customer_pn",:scope=> "agusta.agusta_inquiry"),"3"],[I18n.t("order_number",:scope=> "agusta.agusta_inquiry"),"4"]]
  end
  # Creates a HTML select Box with user name for Inquiry Search
  def self.uname(users)
    users.unshift(I18n.t("select",:scope=> "agusta"))
    data = users.zip(users)
    data[0][1]=nil
    select_tag_values = data
  end
  # Creates a HTML select Box with order Source for Inquiry Search [Bar, Desk, ALL]
  def self.order_source
    select_tag_values = [[I18n.t("select",:scope=> "agusta"),nil],[I18n.t("desk",:scope=> "agusta.agusta_inquiry"),"D"],[I18n.t("bar",:scope=> "agusta.agusta_inquiry"),"B"],[I18n.t("all",:scope=> "agusta.agusta_inquiry"),"A"]]
  end
  # Creates a HTML select Box with Order Status for Inquiry Search [On Back Order, Out For delivery , Delivered]
  def self.order_status
    select_tag_values = [[I18n.t("select_status",:scope=> "agusta.agusta_inquiry"),nil],[I18n.t("open",:scope=> "agusta.agusta_inquiry"),"O"],[I18n.t("out_for_delivery",:scope=> "agusta.agusta_inquiry"),"OFD"],[I18n.t("on_back_order",:scope=> "agusta.agusta_inquiry"),"OBO"],[I18n.t("delivered",:scope=> "agusta.agusta_inquiry"),"D"]]
  end

  def self.get_ad_hoc_orders
    Order.where("order_type = ? or order_type = ? and auto_cancelled = ?", "SOS", "CRIB", false)
  end

  def add_kit_part_number
    if self.order_type == "CRIB"
      kit = Kitting::Kit.find_by_id(self.kit_part_number)
      if kit
        self.update_attribute("kit_part_number",kit.customer_kit_part_number)
      end
    end
  end

end
