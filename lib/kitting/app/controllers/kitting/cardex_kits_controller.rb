require_dependency "kitting/application_controller"

module Kitting
  class CardexKitsController < ApplicationController
    layout "kitting/cardex_kit_layout", only: [:detail_design]
    before_filter :get_all_media_type, :only => [:index,:search,:detail_design]
    include Kitting::CardexKitsHelper
    def index
      @kitting_response = invoke_webservice method: 'get', action: 'kitCompInfo',query_string: {kitPartNo: params[:kit_number]}
    end

    def search
      @kitting_response = invoke_webservice method: 'get', action: 'kitCompInfo',query_string: {kitPartNo: params[:kit_number]}
      @cardex_kit = Kitting::CardexKit.find_by_kit_number_and_parent_kit_id(params[:kit_number],nil)
      if @kitting_response
        if @kitting_response["errCode"] == "0"
          @total_parts = @kitting_response["kitCompPartNo"].size.to_i
          flash.now[:notice] = "Kit <strong>"+@kitting_response["kitPartNo"] +"</strong> found with "+@total_parts.to_s+ " parts, select media type for this kit.".html_safe
          render "index"
        else
          flash.now[:alert] = @kitting_response["errMsg"]
          render 'index'
        end
      else
        flash.now[:notice] = "Service temporary unavailable"
        render "index"
      end
    end

    def detail_design
      if params[:mmt_id].present? && params[:sub_kit].present?
        @mmt = Kitting::CardexKit.find_by_id(params[:mmt_id])
        @cardex_kit = Kitting::CardexKit.find_by_id(params[:sub_kit])
        kit_media_type = Kitting::KitMediaType.find_by_id(params[:kit_media_type])
        @kit_number = @cardex_kit.kit_number
      else
        @cardex_kit = Kitting::CardexKit.find_by_kit_number(params[:kit_number])
        kit_media_type = Kitting::KitMediaType.find_by_id(params[:kit_media_type])
        @kit_number = params[:kit_number]
      end
      cup_layout = ''
      if @cardex_kit
        cup_layout = @cardex_kit.kit_html_layout
        # @kit_bom_details = get_bom_detail(params[:kit_number])
      else
        cup_layout = fetch_cup_layout(kit_media_type)
      end
      @kitting_response = invoke_webservice method: 'get', action: 'kitCompInfo',query_string: {kitPartNo: @kit_number}
      if kit_media_type && @kitting_response
        if @kitting_response["errCode"] == "0"
          if @cardex_kit
            @cardex_kit.update_attributes(kit_media_type_id: kit_media_type,:kit_html_layout =>  cup_layout, updated_by: current_customer)
          else
            @cardex_kit = kit_media_type.cardex_kits.new(:kit_number => params[:kit_number],:kit_html_layout =>  cup_layout, created_by: current_customer, update_by: current_customer)
            @cardex_kit.save
          end
          @total_parts = @kitting_response["kitCompPartNo"]
          if kit_media_type.kit_type == "multi-media-type" || @mmt
            @mmt_kit = @cardex_kit.is_mmt? ? @cardex_kit : @cardex_kit.mmt_kit
            @multi_media_kits = @mmt.sub_kits.sort rescue []
            @used_parts = get_used_parts @multi_media_kits.map(&:kit_html_layout)
            @unused_parts = @total_parts - @used_parts.map { |usp|
              if usp.include?("#")
                usp.split("#").map { |mixed_part| mixed_part.split(" ")[0] }.flatten
              else
                usp.split(" ")[0]
              end
            }.flatten
          else
            @used_parts = get_used_parts [@cardex_kit.kit_html_layout]
            @unused_parts = @total_parts - @used_parts.map { |usp|
              if usp.include?("#")
                usp.split("#").map { |mixed_part| mixed_part.split(" ")[0] }.flatten
              else
                usp.split(" ")[0]
              end
            }.flatten
          end
          flash.now[:notice] = "Kit <strong>"+@kitting_response["kitPartNo"] +"</strong> found with "+@total_parts.count.to_s+ " parts, select media type for this kit.".html_safe
        else
          flash.now[:alert] = @kitting_response["errMsg"]
        end
      else
        flash.now[:notice] = kit_media_type.present? ? "Service temporary unavailable" : "Kit Media type #{params[:kit_media_type]} not found ."
      end
    end

    def build_part
      @part = Kitting::Part.find_by_part_number(params[:part_number])
      if @part
        respond_to do |format|
          format.js { render :status => status }
        end
      end
    end

    def save_layout
      if params[:mmt_kit] && params[:mmt_kit].strip.present? && params[:cardex_kit] && params[:cardex_kit].present?
        @cardex_kit = Kitting::CardexKit.find_by_id(params[:cardex_kit])
      else
        @cardex_kit = Kitting::CardexKit.find_by_kit_number(params[:kit_number])
      end
      @kit_media_type = @cardex_kit.kit_media_type
      @kit_type = @kit_media_type.kit_type
      kit_html_layout = []
      if @kit_type == "configurable"
        kit_html_layout << JSON[params[:kit_html_layout]]
        kit_html_layout << JSON[params[:kit_html_layout1]]
        kit_html_layout << JSON[params[:kit_html_layout2]]
        @kit_html_layout = kit_html_layout
      else
        kit_html_layout = JSON[params[:kit_html_layout]]
        @kit_html_layout = kit_html_layout
      end

      if @cardex_kit
        @cardex_kit.update_attributes(kit_media_type_id: @kit_media_type.id ,:kit_html_layout =>  @kit_html_layout.to_json, updated_by: current_customer)
      else
        @cardex_kit = CardexKit.new(:kit_number => @cardex_kit.kit_number , kit_media_type_id: @kit_media_type.id,:kit_html_layout =>  @kit_html_layout.to_json, updated_by: current_customer)
        @cardex_kit.save
      end

      respond_to do |format|
        format.js { }
      end

    end

    def print_template
      @cardex_kit = Kitting::CardexKit.find_by_kit_number_and_parent_kit_id(params[:kit_number],nil)
      if @cardex_kit.is_mmt?
        @merge_path = Array.new
        @cardex_kit.sub_kits.sort.each_with_index do |kit, i|
          @kit_media_type = kit.kit_media_type.name
          @kit_type = kit.kit_media_type.kit_type
          @kit_html_layout = JSON.parse(kit.kit_html_layout)
          @box_number = kit.box_number
          @kit = kit
          save_path = Rails.public_path+"/pdfs/cardex_kit_#{kit.kit_number+ '_' + kit.box_number.to_s}.pdf"
          File.delete(save_path) if File.exist?(save_path)
          if @kit_type == "configurable"
            pdf = WickedPdf.new.pdf_from_string( render_to_string("print_template.html.erb" , :layout => false),:orientation => 'Landscape',:margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 })
            File.open(save_path, 'wb') do |file|
              file << pdf
            end
          else
            pdf = WickedPdf.new.pdf_from_string( render_to_string("print_template.html.erb" , :layout => false),:orientation => 'Landscape',:margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 })
            File.open(save_path, 'wb') do |file|
              file << pdf
            end
          end
          @merge_path << save_path
        end
        File.delete(Rails.public_path+"/pdfs/Cardex_Kit_#{@cardex_kit.kit_number}.pdf") if File.exist?(Rails.public_path+"/pdfs/Cardex_Kit_#{@cardex_kit.kit_number}.pdf")
        str = "#{Pdftk.config[:exe_path]} #{@merge_path.join(" ")} output #{Rails.public_path+"/pdfs/Cardex_Kit_#{@cardex_kit.kit_number}.pdf"} dont_ask"
        Open3.popen3(str)
        sleep 3
        respond_to do |format|
          format.html do
            send_file(File.open(Rails.public_path+"/pdfs/Cardex_Kit_#{@cardex_kit.kit_number}.pdf"),:filename=> "CARDEX KIT",:disposition => "inline",:type => "application/pdf")
          end
        end
      else
        @kit_media_type = @cardex_kit.kit_media_type
        @kit_type = @cardex_kit.kit_media_type.kit_type
        kit_html_layout = []
        if @kit_type == "configurable"
          kit_html_layout << JSON[params[:kit_html_layout]]
          kit_html_layout << JSON[params[:kit_html_layout1]]
          kit_html_layout << JSON[params[:kit_html_layout2]]
          @kit_html_layout = kit_html_layout
        else
          kit_html_layout = JSON[params[:kit_html_layout]]
          @kit_html_layout = kit_html_layout
        end
        if @cardex_kit
          @cardex_kit.update_attributes(kit_media_type_id: @kit_media_type.id ,:kit_html_layout =>  @kit_html_layout.to_json, updated_by: current_customer)
        else
          @cardex_kit = CardexKit.new(:kit_number => @cardex_kit.kit_number , kit_media_type_id: @kit_media_type.id,:kit_html_layout =>  @kit_html_layout.to_json, updated_by: current_customer)
          @cardex_kit.save
        end
        @kit_media_type = @cardex_kit.kit_media_type.name
        if @kit_type == "configurable"
          respond_to do |format|
            format.html do
              render :pdf => "print_template.html.erb",
                     :orientation => 'Landscape',
                     :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
            end
          end
        else
          respond_to do |format|
            format.html do
              render :pdf => "print_template.html.erb",
                     :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
            end
          end
        end
      end
    end

    def add_remove_mmt_kit
      @cardex_kit = Kitting::CardexKit.find_by_id(params[:id])
      @kit_media_type = Kitting::KitMediaType.find_by_id(params[:kit_media_type])
      if params[:type] == "add"
        if @kit_media_type && @cardex_kit
          cup_layout = fetch_cup_layout(@kit_media_type)
          status= false
          unless @cardex_kit.sub_kits.empty?
            kit_status = get_empty_kits @cardex_kit.sub_kits.map(&:kit_html_layout)
            status = kit_status.map(&:empty?).include?(true)
          end
          if status
            @error = "Save Current Layout / Fill Empty Kit first before adding Sub Kit."
          else
            @sub_kit = @cardex_kit.sub_kits.new(:kit_number => @cardex_kit.kit_number , kit_media_type_id: @kit_media_type.id,:kit_html_layout => cup_layout, updated_by: current_customer)
            if @sub_kit.save
              @sub_kit.mmt_kit.sub_kits.sort.each_with_index do |kit,index|
                kit.update_attribute("box_number",index+1);
              end
              render :js => "window.location = '/kitting/cardex_kits/detail_design?mmt_id=#{@cardex_kit.id}&kit_media_type=#{@kit_media_type.id}&sub_kit=#{@sub_kit.id}'"
            else
              @error = "Error while saving selected media type."
            end
          end
        else
          @error = "MMT KIT NOT FOUND"
        end
      else
        @mmt_kit = @cardex_kit.mmt_kit
        @cardex_kit.destroy
        @mmt_kit.sub_kits.sort.each_with_index do |kit,index|
          kit.update_attribute("box_number",index+1);
        end
        @sub_kit = @mmt_kit.sub_kits.sort
        if @sub_kit.empty?
          render :js => "window.location = '/kitting/cardex_kits/detail_design?kit_number=#{@mmt_kit.kit_number}&kit_media_type=#{@mmt_kit.kit_media_type.id}'"
        else
          render :js => "window.location = '/kitting/cardex_kits/detail_design?mmt_id=#{@mmt_kit.id}&kit_media_type=#{@sub_kit.first.kit_media_type.id}&sub_kit=#{@sub_kit.first.id}'"
        end
      end
    end

    def reset_layout
      @cardex_kit = Kitting::CardexKit.find_by_id(params[:id])
      if @cardex_kit
        @cardex_kit.destroy
        respond_to do |format|
          flash.now[:notice] = "Kit " + @cardex_kit.kit_number + " reset successfully"
          format.html { render 'index' }
        end
      else
        respond_to do |format|
          format.html { redirect_to cardex_kits_path }
        end
      end
    end

    private
    def get_all_media_type
      @kit_media_types = Kitting::KitMediaType.where("customer_number = ?",current_user)
    end
  end
end