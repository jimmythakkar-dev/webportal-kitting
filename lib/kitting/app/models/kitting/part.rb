module Kitting
  class Part < ActiveRecord::Base
    self.table_name = "parts"
    attr_accessible :description, :image_name, :part_number, :status, :name, :customer_number,:large_cup_count, :medium_cup_count, :small_cup_count,:prime_pn
    mount_uploader :image_name, ImageNameUploader
    has_many :cup_parts
    has_many :cups, :through => :cup_parts
    #belongs_to :customer
    validates :part_number, uniqueness: true
    validates :part_number, presence: true
    validates :large_cup_count, :numericality => {:only_integer => true}, :allow_nil => true
    validates :medium_cup_count, :numericality => {:only_integer => true}, :allow_nil => true
    validates :small_cup_count, :numericality => {:only_integer => true}, :allow_nil => true
=begin
    validates :number, :image_name, presence: true
=end
    validate :is_valid_cup_count? # validate if the order of cup count i.e large/medium/small is in order

    def is_valid_cup_count?
      if (self.large_cup_count.present? || self.medium_cup_count.present? || self.small_cup_count.present?)
        part_small_cup_count = self.small_cup_count || small_cup_count
        part_medium_cup_count = self.medium_cup_count || medium_cup_count
        part_large_cup_count =  self.large_cup_count || large_cup_count
        if(part_large_cup_count < part_medium_cup_count && part_medium_cup_count > 0)
          errors.add(:base,"Large Cup Count should be Greater than Medium Cup Count")  #adds error to Active Model in order to stop record from being saved
        else
          if(part_medium_cup_count < part_small_cup_count && part_small_cup_count > 0)
            errors.add(:base,"Medium Cup Count should be Greater than Small Cup Count")
          else
            return true
          end
        end
      end
    end
  end
end