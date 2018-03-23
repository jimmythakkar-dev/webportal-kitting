require_dependency "kitting/application_controller"

module Kitting
  class KitFillingHistoryController < ApplicationController
    before_filter :get_acess_right

    def show
      kit_filling = Kitting::KitFilling.find_by_id(params[:kit_filling])
      items = Kitting::KitFilling.find_by_id(kit_filling.id).kit_filling_details.map{|kfd| kfd.id}
      @versions = Version.where("(item_type = 'Kitting::KitFilling' AND item_id = #{kit_filling.id})
                                  OR (item_type = 'Kitting::KitFillingDetail' AND item_id IN (#{kit_filling.kit_filling_details.map{|kfd| kfd.id}.flatten.join(',')}))")
      if @versions.blank?
        flash.now[:notice] = "There is no fill history for the kit"
      else
        @versions.sort!
      end
    end
  end
end