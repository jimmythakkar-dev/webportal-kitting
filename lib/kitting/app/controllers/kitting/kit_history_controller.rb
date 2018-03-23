require_dependency "kitting/application_controller"

module Kitting
  class KitHistoryController < ApplicationController
    before_filter :get_acess_right, :except => [:show]
    layout "kitting/fit_to_compartment", :only => [:show ]
    def show
      kit = Kitting::Kit.find_by_id(params[:kit])
      if kit.kit_media_type.kit_type = "multi-media-type"
        @mmt_kits = Kitting::Kit.find_all_by_parent_kit_id(kit.id)
        @versions = Array.new
        @versions << Version.where("(item_type = 'Kitting::Kit' AND item_id = #{kit.id})")
        @mmt_kits.each do |mmt_kit|
          @versions << Version.where("(item_type = 'Kitting::Kit' AND item_id = #{mmt_kit.id}) OR (item_type = 'Kitting::CupPart' AND item_id IN (#{mmt_kit.cups.map{|cup| cup.cup_parts.map {|cup_part| cup_part.id}}.flatten.join(',')}))")
        end
      else
        @versions = Version.where("(item_type = 'Kitting::Kit' AND item_id = #{kit.id}) OR (item_type = 'Kitting::CupPart' AND item_id IN (#{kit.cups.map{|cup| cup.cup_parts.map {|cup_part| cup_part.id}}.flatten.join(',')}))")
      end
      if @versions.blank?
        flash.now[:notice] = "There is no history for the kit"
      else
        @versions.flatten!.sort!
      end
    end
  end
end