module Kitting
  class Kit < ActiveRecord::Base
    self.table_name = "kits"
    attr_accessible :current_version,:edit_status, :commit_status, :commit_id, :flag,:notes,:description, :kit_media_type_id, :bincenter,:kit_number, :approved, :status, :location_id,:created_by,:customer_id,:part_bincenter,:cust_no,:updated_by, :parent_kit_id, :deleted  # Associations Defination
    has_many :cups, :dependent => :destroy
    has_many :cup_parts, through: :cups
    belongs_to :kit_media_type
    belongs_to :customer
    has_many :kit_copies, :dependent => :destroy
    belongs_to :location
    has_many :kit_status_details
    has_many :kit_work_orders
    has_many :work_orders, :through => :kit_work_orders
    # Validations Start
    validates :kit_media_type_id, :bincenter, :kit_number, :presence => true
    validates :kit_number, :uniqueness => true

    has_paper_trail

    # scope :fetch_kit, ->(ids) {where("(status is ? or status = ?) and (kit_number not in (?))", nil, 2 ,ids) }
    scope :fetch_approved_kit, ->(ids) {where("(status = ? or status = ?) and (kit_number not in (?))",nil, 1,ids) }

    ##
    # Create cups for a kit based on the kit media type
    ##
    def create_cups kit, number_of_compartments
      for i in 1..number_of_compartments
        kit.cups.create(:commit_status => false, :status => true, :cup_number => i.to_i)
      end
    end

    # FETCH MULTIMEDIA CUPS
    def mmt_cups
        ApplicationController.helpers.get_commited_data.call self.class.where(:parent_kit_id => self.id,:commit_status => true),"cups"
    end

    ##
    # Create cups for a kit for a binder type of kit.
    ##
    def create_binder_cups kit, number_of_compartments,commit_status,index=1
      for i in index..number_of_compartments
        kit.cups.create(:commit_status => commit_status, :status => true, :cup_number => i.to_i)
      end
    end

    ##
    # Create cups for a kit for a configurable type of kits.
    ##
    def create_config_cups kit, number_of_compartments, cup_layouts
      cup_count = 0
      cup_layouts.each_with_index do |cup_layout,index|
        cup_layout = cup_layout.sort { |a,b| a[1] <=> b[1] }
        cup = Array.new
        cup_layout.each { |cl| cup << cl.at(1) }
        cup.uniq!
        record_to_sort = Array.new
        cup.each { |record|
          record_to_sort << cup_layout.select { |data| data[1] == record }
        }
        cup_layout = Array.new
        record_to_sort.each { |rec|
          record = rec.sort! { |a,b| a[0] <=> b[0] }
          record.each { |new_rec| cup_layout << new_rec }
        }
        number_of_compartments = cup_layout.count
        index = index + 1

        for i in 0..number_of_compartments-1
          cup_id = kit.cups.create(:commit_status => false,:cup_dimension => cup_layout[i].join(','),:cup_number => cup_count + i+1, :status => 1)
          cup_id.update_attribute("cup_dimension",cup_id.cup_dimension+",#{index}"+",#{cup_id.id}")
        end
        cup_count = cup_count + (i + 1)
      end
      cup_count =0
    end

    ##
    # Update cup layout for a kit for a configurable type of kits.
    ##
    def update_config_cups kit, cup_layouts,current_customer, approval = false
      cup_count = 0
      cup_layouts.each_with_index do |cup_layout,index|
        cup_layout = cup_layout.sort { |a,b| a[1] <=> b[1] }
        cup = Array.new
        cup_layout.each { |cl| cup << cl.at(1) }
        cup.uniq!
        record_to_sort = Array.new
        cup.each { |record|
          record_to_sort << cup_layout.select { |data| data[1] == record }
        }
        cup_layout = Array.new
        record_to_sort.each { |rec|
          record = rec.sort! { |a,b| a[0] <=> b[0] }
          record.each { |new_rec| cup_layout << new_rec }
        }
        number_of_compartments = cup_layout.count
        for i in 0...number_of_compartments
          cup_id = cup_layout[i].last
          cup = kit.cups.find_by_id(cup_id)
          cup_updated = kit.cups.find_by_commit_id(cup_id)
          if cup_updated.present?
            cup_updated.update_attributes(:cup_dimension => cup_layout[i].join(','), :cup_number => cup_count + i+1)
          else
            if cup
              old_layout = cup.cup_dimension
              if cup.commit_status && old_layout != cup_layout[i].join(',')
                if approval == false
                  unless cup_updated
                    ActiveRecord::Base.transaction do
                      new_cup = cup.dup
                      new_cup.save(:validate => false)
                      new_cup.update_attributes(:cup_dimension => cup_layout[i].join(','), :commit_status => false, :cup_number => cup_count + i+1, :commit_id => cup.id )
                      new_kit = kit.parent_kit_id ? Kitting::Kit.find_by_id(kit.parent_kit_id) : kit
                      @dup_kit = Kitting::Kit.find_by_commit_id_and_commit_status(new_kit.id,false)
                      if @dup_kit.present?
                        @dup_kit.update_attribute("updated_by",current_customer.id)
                      else
                        @dup_kit = new_kit.dup
                        @dup_kit.commit_status = false
                        @dup_kit.commit_id = new_kit.id
                        @dup_kit.status = 2
                        @dup_kit.updated_by= current_customer.id
                        @dup_kit.save(:validate => false)
                      end
                    end
                  end
                end
              else
                cup.update_attributes(:cup_dimension => cup_layout[i].join(','), :cup_number => cup_count + i+1)
              end
            else
              cup_count = cup_count + i+ 1
            end
          end
        end
        cup_count = cup_count + (i + 1) if i
      end
      cup_count = 0
    end

    ##
    # Create one default copy of a kit first time when a kit is approved.
    ##
    def create_default_copy(kit, current_customer)

      copy_version_number = get_copy_kit_number(kit.id)
      loc = Kitting::Location.where('name = ?', "NEW KIT QUEUE")
      @kit_copy = current_customer.kit_copies.create(:kit_id => kit.id, :kit_version_number => kit.kit_number + "-"+ copy_version_number, :status => kit.status, location_id: loc.first.id, :version_status => kit.current_version )
      ###################  START TO INSERT INTO TRACK COPY VERSION #############
      if @kit_copy.present?
        @track_version = Kitting::TrackCopyVersion.create(kit_copy_id: @kit_copy.id, version: @kit_copy.version_status, picked_version:  @kit_copy.version_status, filled_version:  @kit_copy.version_status)
      end
      ################### STOP TRACK COPY VERSION ##############################

      # if kit.kit_media_type.kit_type == "multi-media-type"
      #   mmt_kit = Kitting::Kit.find_all_by_parent_kit_id_and_deleted(kit.id, false)
      #   mmt_kit.each_with_index do |kit, index|
      #     copy_version_number = get_copy_kit_number(kit.id)
      #     loc = Kitting::Location.where('name = ?', "NEW KIT QUEUE")
      #     @mmt_kit_copy = current_customer.kit_copies.create(:kit_id => kit.id, :kit_version_number => kit.kit_number + "-"+ copy_version_number, :status => kit.status, location_id: loc.first.id, :version_status => kit.current_version, :parent_kit_copy_id => @kit_copy.id )
      #     ###################  START TO INSERT INTO TRACK COPY VERSION #############
      #     if @mmt_kit_copy.present?
      #       @track_version = Kitting::TrackCopyVersion.create(kit_copy_id: @mmt_kit_copy.id, version: @mmt_kit_copy.version_status, picked_version:  @mmt_kit_copy.version_status, filled_version:  @mmt_kit_copy.version_status)
      #     end
      #     ################### STOP TRACK COPY VERSION ##############################
      #   end
      # end

    end

    ##
    # Get next Copy number of the kit.
    ##
    def get_copy_kit_number id
      if Kitting::KitCopy.find_all_by_kit_id(id).blank?
        count = 1
      else
        count = Kitting::KitCopy.find_all_by_kit_id(id).count + 1
      end
      count.to_s
    end

    ##
    # RETURNS JSON DATA i.e to be sent to cardex
    ##
    def self.get_kit_data(orig_kit,kit_type="normal",box_num=0)
      misc=Array.new;parts=Array.new;quantity=Array.new;uom=Array.new;cup_part_in_contract=Array.new
      @cups = Kitting::Cup.find_all_by_kit_id_and_commit_id_and_status(orig_kit.id,nil,true).sort
      @cups.each_with_index do |cup,cup_index|
        @cup_to_display = Kitting::Cup.find_all_by_kit_id_and_commit_id_and_status(orig_kit.id,cup.id,true).sort
        if @cup_to_display.present?
          orig_hash =Hash.new; dup_hash =Hash.new
          cup.cup_parts.where(:commit_id => nil).map { |cp| orig_hash[cp.id]= cp.commit_id }
          cup.cup_parts.where(cup.cup_parts.arel_table[:commit_id].not_eq(nil)).map { |cp| dup_hash[cp.id]= cp.commit_id }
          orig_hash.merge!(dup_hash.invert)
          valid_hash = orig_hash.inject({}) { |h, (k, v)| h[k] = k if v.nil?; h }
          cuppart_ids = orig_hash.merge(valid_hash).values
          cuppart_ids.each { |cup_part|
            valid_cup_part = Kitting::CupPart.find(cup_part)
            if valid_cup_part.status
              uom <<  valid_cup_part.uom
              if orig_kit.kit_media_type.kit_type == "configurable"
                if kit_type == "multi-media-type"
                  misc << "#{@cup_to_display.first.id}-#{box_num+1}/#{@cup_to_display.first.cup_number}"
                else
                  misc << "#{@cup_to_display.first.id}-#{@cup_to_display.first.cup_number}"
                end
              else
                if kit_type == "multi-media-type"
                  misc << "#{@cup_to_display.first.id}-#{box_num+1}/#{cup.cup_number}"
                else
                  misc << "#{@cup_to_display.first.id}-#{cup.cup_number}"
                end
              end
              parts << valid_cup_part.part.part_number.upcase
              quantity << valid_cup_part.demand_quantity
              cup_part_in_contract << valid_cup_part.in_contract?
            end
          }
        else
          orig_hash =Hash.new; dup_hash =Hash.new
          cup.cup_parts.where(:commit_id => nil).sort.map { |cp| orig_hash[cp.id]= cp.commit_id }
          cup.cup_parts.where(cup.cup_parts.arel_table[:commit_id].not_eq(nil)).sort.map { |cp| dup_hash[cp.id]= cp.commit_id }
          orig_hash.merge!(dup_hash.invert)
          valid_hash = orig_hash.inject({}) { |h, (k, v)| h[k] = k if v.nil?; h }
          cuppart_ids = orig_hash.merge(valid_hash).values
          cuppart_ids.each { |cup_part|
            valid_cup_part = Kitting::CupPart.find(cup_part)
            if valid_cup_part.status
              uom << valid_cup_part.uom
              if orig_kit.kit_media_type.kit_type == "configurable"
                if kit_type == "multi-media-type"
                  misc << "#{cup.id}-#{box_num+1}/#{cup.cup_number}"
                else
                  misc << "#{cup.id}-#{cup.cup_number}"
                end
              else
                if kit_type == "multi-media-type"
                  misc << "#{cup.id}-#{box_num+1}/#{cup.cup_number}"
                else
                  misc << "#{cup.id}-#{cup.cup_number}"
                end
              end
              parts << valid_cup_part.part.part_number.upcase
              quantity << valid_cup_part.demand_quantity
              cup_part_in_contract << valid_cup_part.in_contract?
            end
          }
        end
      end
      return { :misc =>misc,:parts=>parts,:quantity => quantity, :uom=> uom ,:in_contract_status => cup_part_in_contract }
    end
  end
end
