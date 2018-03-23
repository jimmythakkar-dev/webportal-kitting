require_dependency "kitting/application_controller"

module Kitting
  class VersionsController < ApplicationController
    ##
    #  This action is called when undoing a kit creation process from the detail_design GUI.
    ##
    def revert
      @version = Version.find(params[:id])
      if @version.reify
        @version.reify.save!
      else
        @version.item.destroy rescue config.logger.warn "Couldn't find Kit with id #{@version.item_id} to undo.\n Version Object is #{@version.inspect}"
      end
      redirect_to kits_path, :notice => "Undid #{@version.event} Kit"
    end
  end
end