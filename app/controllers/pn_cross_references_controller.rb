class PnCrossReferencesController < ApplicationController
  before_filter :get_menu_id
  # GET /pn_cross_references
  # GET /pn_cross_references.json
  # Index method renders form to enter part number and submit to search cross references
  def index

  end

  # Searches Cross Reference Part No by Invoking Mule web Service
  def search_pn
    @pn_cross_references = invoke_webservice method: 'get', action: 'xrefParts', query_string: { :partNo => params[:pn_part_number]}
    if @pn_cross_references.present? && @pn_cross_references["errMsg"].blank?
      @xNSN = @pn_cross_references["xNSN"].split(",")
      @xPartNo = @pn_cross_references["xPartNo"].split(",")
      @xCage = @pn_cross_references["xCage"].split(",")
      @xCageName = @pn_cross_references["xCageName"].split(",")
    else
      @error = @pn_cross_references.present? ? @pn_cross_references["errMsg"] : "Service Temporarily Unavailable"
    end
    render :index
  end
end
