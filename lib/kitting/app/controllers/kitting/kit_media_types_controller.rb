require_dependency "kitting/application_controller"

module Kitting
  class KitMediaTypesController < ApplicationController
    before_filter :get_acess_right
    before_filter :conf_media_type, :only => [:new,:index,:create]

    ##
    # This action initializes the New Kit Media Type creation page.
    ##
    def new
      if can?(:>=, "5")
        @kit_media_type = Kitting::KitMediaType.new
        self.class.layout "kitting/application"
        respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @kit_media_type }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action is for creating a new KitMediaType
    ##
    def create
      if can?(:>=, "5")
        if params[:configurable_kmt].present?
          @kit_media_type = Kitting::KitMediaType.find_by_id(params[:configurable_kmt]).dup
          @kit_media_type.description = params[:kit_media_type][:description]
          @kit_media_type.customer_id = current_customer.id
          @kit_media_type.customer_name = session[:customer_Name]
          @kit_media_type.customer_number = session[:customer_number]
        elsif params[:kit_media_type][:kit_type] == "multi-media-type"
          if can?(:>=,"6")
            @kit_media_type = Kitting::KitMediaType.find_by_kit_type(params[:kit_media_type][:kit_type]).dup
            @kit_media_type.description = params[:kit_media_type][:description]
            @kit_media_type.customer_id = current_customer.id
            @kit_media_type.customer_name = session[:customer_Name]
            @kit_media_type.customer_number = session[:customer_number]
          else
            @kit_media_type = "UNAUTHORIZED"
          end
        else
          params[:kit_media_type][:compartment_layout] = params[:kit_media_type][:compartment_layout].to_json
          @kit_media_type = current_customer.kit_media_types.new(params[:kit_media_type])
          @kit_media_type.customer_name = session[:customer_Name]
          @kit_media_type.customer_number = session[:customer_number]
        end
        respond_to do |format|
          if @kit_media_type != "UNAUTHORIZED" && @kit_media_type.save
            format.html { redirect_to @kit_media_type, notice: 'Kit media type is created successfully.' }
            format.json { render json: @kit_media_type, status: :created, location: @kit_media_type }
          else
            if @kit_media_type == "UNAUTHORIZED"
              format.html { redirect_to main_app.unauthorized_url }
            else
              format.html { render action: "new" }
              format.json { render json: @kit_media_type.errors, status: :unprocessable_entity }
            end
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # shows the layout and description of the selected kit media type
    ##
    def show
      if can?(:>=, "5")
        @kit_media_type = Kitting::KitMediaType.find(params[:id])
        respond_to do |format|
          format.html
          format.js {}
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action is of index page  showing KitMediaTypes list as per user access
    ##
    def index
      if can?(:>=, "5")
        @kit_media_types = Kitting::KitMediaType.where(:customer_number => current_customer.cust_no )
        self.class.layout "kitting/application"
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @kit_media_types }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # Edit a KitMediaType
    ##
    def edit
      if can?(:>=, "5")
        @kit_media_type = Kitting::KitMediaType.find(params[:id])
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # After editing a KitMediaType its updated layout and description.
    ##
    def update
      if can?(:>=, "5")
        params[:kit_media_type][:compartment_layout] = params[:kit_media_type][:compartment_layout].to_json
        @kit_media_type = Kitting::KitMediaType.find(params[:id])
        respond_to do |format|
          if @kit_media_type.update_attributes(params[:kit_media_type])
            format.html { redirect_to @kit_media_type, notice: 'Kit media type is updated successfully.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @kit_media_type.errors, status: :unprocessable_entity }
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action is called when a kit is searched from kit search screen and is filtered by kitmediatype.
    ##
    def search_kit
      if can?(:>=, "5")
        if params[:kit_number].present?
          @parent_kit= Kitting::Kit.find_by_kit_number_and_commit_id(params[:kit_number],nil)
          if @parent_kit.present?
            @dup_kit = Kitting::Kit.find_by_commit_id(@parent_kit.id) if @parent_kit.present?
            @kit_media_type = @parent_kit.kit_media_type
            if @parent_kit.kit_media_type.kit_type == "multi-media-type"
              @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@parent_kit.id,true).sort
              if params[:mmt_kit_id] && !params[:mmt_kit_id].empty?
                @mmt_kit_id = Kitting::Kit.find(params[:mmt_kit_id])
                if @mmt_kit_id.deleted
                  @mmt_kit_id = @multi_media_kits.first
                else
                  @mmt_kit_id = @mmt_kit_id
                end
              end
              @kit = @mmt_kit_id || @multi_media_kits.first
              @mmt_kit_media_type = @kit.kit_media_type
              @media_types= Kitting::KitMediaType.where("name NOT IN (?) and  customer_number = ?",[@kit_media_type.name,"--",@mmt_kit_media_type.name],current_user)
            else
              @kit = @parent_kit
              @media_types= Kitting::KitMediaType.where("name NOT IN (?) and  customer_number = ?",[@kit_media_type.name,"--","Multiple Media Type"],current_user)
            end
            self.class.layout "kitting/fit_to_compartment"
          else
            flash[:error] = "No Such Kit Found. Enter a Valid Kit Number."
            redirect_to :back
          end
        else
          self.class.layout "kitting/application"
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # Convert KitMediaType from non-configurable to configurable and vice-versa
    ##
    def convert_media_type
      if can?(:>=, "5")
        @kit = Kitting::Kit.find_by_kit_number_and_commit_id(params[:kit_number],nil)
        @current_kit_media_type=@kit.kit_media_type
        @media_type_to_convert= Kitting::KitMediaType.find(params[:media_type])
        # if  @current_kit_media_type.kit_type == "configurable" or @media_type_to_convert.kit_type == "configurable"
        #   flash[:error] = "Cannot Convert Kit Media of Configurable/Service Not Available"
        #   redirect_to :back
        # else
        if @media_type_to_convert.kit_type == "binder" and @current_kit_media_type.kit_type == "binder"
          flash[:error] = "Cannot Convert Kit Media of Same Type(binder-binder) "
          redirect_to :back
        else
          if @current_kit_media_type.kit_type == "binder"
            if @media_type_to_convert.kit_type == "configurable"
              @cups_to_delete = Kitting::Cup.where("kit_id = ? and id NOT IN (?)",@kit.id,@kit.cup_parts.select { |cp| cp.status ==true }.map(&:cup_id))
              @cups_to_delete.map(&:destroy)
              if @kit.cups.count <= @media_type_to_convert.compartment
                config.logger.warn "{\"Msg\":\"Changing Kit Media Type for #{@kit.kit_number} from #{@current_kit_media_type.name} to #{@media_type_to_convert.name}.\"}" rescue ""
                cup_size = @media_type_to_convert.compartment - @kit.cups.count
                cup_count = @kit.cups.count
                cup_size = @media_type_to_convert.compartment - cup_count
                @kit.create_binder_cups(@kit,cup_count+cup_size,true, cup_count+1)
                if (@media_type_to_convert.compartment == 18)
                  cup_layout = [[1, 1, 1, 1, 1], [2, 1, 1, 1 ,1], [3, 1, 1, 1 ,1], [1, 2, 1, 1, 1], [2, 2, 1, 1, 1], [3, 2, 1, 1, 1],
                                [1, 3, 1, 1, 1], [2, 3, 1, 1, 1], [3, 3, 1, 1, 1], [1, 4, 1, 1, 1], [2, 4, 1, 1, 1], [3, 4, 1, 1, 1],
                                [1, 5, 1, 1, 1], [2, 5, 1, 1, 1], [3, 5, 1, 1, 1], [1, 6, 1, 1, 1], [2, 6, 1, 1, 1], [3, 6, 1, 1, 1]]
                elsif (@media_type_to_convert.compartment == 48)
                  cup_layout = [[1, 1, 1, 1, 1], [2, 1, 1, 1, 1], [3, 1, 1, 1, 1], [4, 1, 1, 1, 1], [5, 1, 1, 1, 1], [6, 1, 1, 1, 1], [7, 1, 1, 1, 1], [8, 1, 1, 1, 1], [9, 1, 1, 1, 1], [10, 1, 1, 1, 1],
                                [1, 2, 1, 1, 1], [2, 2, 1, 1, 1], [3, 2, 1, 1, 1], [4, 2, 1, 1, 1], [5, 2, 1, 1, 1], [6, 2, 1, 1, 1], [7, 2, 1, 1, 1], [8, 2, 1, 1, 1], [9, 2, 1, 1, 1], [10, 2, 1, 1, 1],
                                [1, 3, 1, 1, 1], [2, 3, 1, 1, 1], [3, 3, 1, 1, 1], [4, 3, 1, 1, 1], [5, 3, 1, 1, 1], [6, 3, 1, 1, 1], [7, 3, 1, 1, 1], [8, 3, 1, 1, 1], [9, 3, 1, 1, 1], [10, 3, 1, 1, 1],
                                [1, 4, 1, 1, 1], [2, 4, 1, 1, 1], [3, 4, 1, 1, 1], [4, 4, 1, 1, 1], [5, 4, 1, 1, 1], [6, 4, 1, 1, 1], [7, 4, 1, 1, 1], [8, 4, 1, 1, 1], [9, 4, 1, 1, 1], [10, 4, 1, 1, 1],
                                [1, 1, 1, 1, 2], [2, 1, 1, 1, 2], [1, 2, 1, 1, 2], [2, 2, 1, 1, 2],
                                [1, 1, 1, 1, 3], [2, 1, 1, 1, 3], [1, 2, 1, 1, 3], [2, 2, 1, 1, 3]]
                else
                  cup_layout = [[ 1,1,2,1,1], [3,1,2,1,1],[5,1,2,1,1],
                                [1,1,2,1,2], [3,1,2,1,2], [5,1,2,1,2],
                                [1,1,1,1,3], [2,1,2,1,3], [4,1,2,1,3], [6,1,1,1,3]]
                end
                @kit.cups.sort.each_with_index do |cup,index|
                  cup.update_attributes(:cup_dimension => cup_layout[index].join(',') + ",#{cup.id}" )
                end
                @kit.update_attribute("kit_media_type_id",@media_type_to_convert.id)
                flash[:success] ="Changed Kit Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                redirect_to :back
              else
                flash[:error] = "Delete Cups/Parts from Cup to Convert Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                redirect_to :back
              end
            else
              config.logger.warn "{\"Msg\":\"Changing Kit Media Type for #{@kit.kit_number} from #{@current_kit_media_type.name} to #{@media_type_to_convert.name}.\"}" rescue ""
              @cups_to_delete = Kitting::Cup.where("kit_id = ? and id NOT IN (?)",@kit.id,@kit.cup_parts.select { |cp| cp.status ==true }.map(&:cup_id))
              @cups_to_delete.map(&:destroy)
              if @kit.cups.count <= @media_type_to_convert.compartment
                config.logger.warn "{\"Msg\":\"Changing Kit Media Type for #{@kit.kit_number} from #{@current_kit_media_type.name} to #{@media_type_to_convert.name}.\"}" rescue ""
                cup_size = @media_type_to_convert.compartment - @kit.cups.count
                @kit.create_binder_cups(@kit,cup_size,true)
                @kit.update_attribute("kit_media_type_id",@media_type_to_convert.id)
                @kit.cups.sort.each_with_index do |cup,index|
                  cup.update_attribute("cup_number",index+1)
                end
                flash[:success] = "Changed Kit Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                redirect_to :back
              else
                flash[:error] = "Delete Cups/Parts from Cup to Convert Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                redirect_to :back
              end
            end
            #Change Media Type from Configurable to Non-Configurable
          elsif @current_kit_media_type.kit_type == "configurable"
            if @media_type_to_convert.kit_type == "binder"
              flash[:error] = "Cannot Convert Media Type to Binder"
              redirect_to :back
            elsif @media_type_to_convert.kit_type == "non-configurable"
              config.logger.warn "{\"Msg\":\"Changing Kit Media Type for #{@kit.kit_number} from #{@current_kit_media_type.name} to #{@media_type_to_convert.name}.\"}" rescue ""
              cup_count = @kit.cups.where('status = ?',true).count
              delete_cups = @kit.cups.where('status = ?',false).map(&:destroy)
              if cup_count <= @media_type_to_convert.compartment
                cup_size = @media_type_to_convert.compartment - cup_count
                @kit.create_binder_cups(@kit,@kit.cups.count+cup_size,true,@kit.cups.count+1)
                @kit.update_attribute("kit_media_type_id",@media_type_to_convert.id)
                flash[:success] = "Changed Kit Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                redirect_to :back
              else
                cup_count = @kit.cups.where('status = ?',true).count
                delete_cups = @kit.cups.where('status = ?',false).map(&:destroy)
                cup_size = cup_count - @media_type_to_convert.compartment
                @cups = @kit.cups.order("cup_number asc").last(cup_size)
                @check_cup_part = Kitting::CupPart.where("cup_id IN (?) and status = ? ", @cups.map(&:id), 1)
                if @check_cup_part.empty?
                  @cups.each(&:destroy)
                  @kit.update_attribute("kit_media_type_id",@media_type_to_convert.id)
                  flash[:success] = "Changed Kit Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                  redirect_to :back
                else
                  flash[:error] = "Delete Cups/Parts from Cup to Convert Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                  redirect_to :back
                end
              end
              ## Change Media Type from Configurable to Configurable
            elsif @media_type_to_convert.kit_type == "configurable"
              config.logger.warn "{\"Msg\":\"Changing Kit Media Type for #{@kit.kit_number} from #{@current_kit_media_type.name} to #{@media_type_to_convert.name}.\"}" rescue ""
              delete_cups = @kit.cups.where('status = ?',false).map(&:destroy)
              cup_count = @kit.cups.where('status = ?',true).count
              if cup_count <= @media_type_to_convert.compartment
                cup_size = @media_type_to_convert.compartment - cup_count
                @kit.create_binder_cups(@kit,@kit.cups.count+cup_size,true,@kit.cups.count+1)
                @kit.update_attribute("kit_media_type_id",@media_type_to_convert.id)
                if (@media_type_to_convert.compartment == 18)
                  cup_layout = [[1, 1, 1, 1, 1], [2, 1, 1, 1 ,1], [3, 1, 1, 1 ,1], [1, 2, 1, 1, 1], [2, 2, 1, 1, 1], [3, 2, 1, 1, 1],
                                [1, 3, 1, 1, 1], [2, 3, 1, 1, 1], [3, 3, 1, 1, 1], [1, 4, 1, 1, 1], [2, 4, 1, 1, 1], [3, 4, 1, 1, 1],
                                [1, 5, 1, 1, 1], [2, 5, 1, 1, 1], [3, 5, 1, 1, 1], [1, 6, 1, 1, 1], [2, 6, 1, 1, 1], [3, 6, 1, 1, 1]]
                elsif (@media_type_to_convert.compartment == 48)
                  cup_layout = [[1, 1, 1, 1, 1], [2, 1, 1, 1, 1], [3, 1, 1, 1, 1], [4, 1, 1, 1, 1], [5, 1, 1, 1, 1], [6, 1, 1, 1, 1], [7, 1, 1, 1, 1], [8, 1, 1, 1, 1], [9, 1, 1, 1, 1], [10, 1, 1, 1, 1],
                                [1, 2, 1, 1, 1], [2, 2, 1, 1, 1], [3, 2, 1, 1, 1], [4, 2, 1, 1, 1], [5, 2, 1, 1, 1], [6, 2, 1, 1, 1], [7, 2, 1, 1, 1], [8, 2, 1, 1, 1], [9, 2, 1, 1, 1], [10, 2, 1, 1, 1],
                                [1, 3, 1, 1, 1], [2, 3, 1, 1, 1], [3, 3, 1, 1, 1], [4, 3, 1, 1, 1], [5, 3, 1, 1, 1], [6, 3, 1, 1, 1], [7, 3, 1, 1, 1], [8, 3, 1, 1, 1], [9, 3, 1, 1, 1], [10, 3, 1, 1, 1],
                                [1, 4, 1, 1, 1], [2, 4, 1, 1, 1], [3, 4, 1, 1, 1], [4, 4, 1, 1, 1], [5, 4, 1, 1, 1], [6, 4, 1, 1, 1], [7, 4, 1, 1, 1], [8, 4, 1, 1, 1], [9, 4, 1, 1, 1], [10, 4, 1, 1, 1],
                                [1, 1, 1, 1, 2], [2, 1, 1, 1, 2], [1, 2, 1, 1, 2], [2, 2, 1, 1, 2],
                                [1, 1, 1, 1, 3], [2, 1, 1, 1, 3], [1, 2, 1, 1, 3], [2, 2, 1, 1, 3]]
                else
                  cup_layout = [[1,1,2,1,1], [3,1,2,1,1],[5,1,2,1,1],
                                [1,1,2,1,2], [3,1,2,1,2], [5,1,2,1,2],
                                [1,1,1,1,3], [2,1,2,1,3], [4,1,2,1,3], [6,1,1,1,3]]
                end
                @kit.cups.sort.each_with_index do |cup,index|
                  cup.update_attributes(:cup_number => index+1, :cup_dimension => cup_layout[index].join(',') + ",#{cup.id}" ,:status => 1)
                end
                flash[:success] = "Changed Kit Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                redirect_to :back
              else
                cup_count = @kit.cups.where('status = ?',true).count
                delete_cups = @kit.cups.where('status = ?',false).map(&:destroy)
                cup_size = cup_count - @media_type_to_convert.compartment
                @cups = @kit.cups.order("cup_number asc").last(cup_size)
                @check_cup_part = Kitting::CupPart.where("cup_id IN (?) and status = ? ", @cups.map(&:id), 1)
                if @check_cup_part.empty?
                  @cups.each(&:destroy)
                  @kit.update_attribute("kit_media_type_id",@media_type_to_convert.id)
                  if (@media_type_to_convert.compartment == 18)
                    cup_layout = [[1, 1, 1, 1, 1], [2, 1, 1, 1 ,1], [3, 1, 1, 1 ,1], [1, 2, 1, 1, 1], [2, 2, 1, 1, 1], [3, 2, 1, 1, 1],
                                  [1, 3, 1, 1, 1], [2, 3, 1, 1, 1], [3, 3, 1, 1, 1], [1, 4, 1, 1, 1], [2, 4, 1, 1, 1], [3, 4, 1, 1, 1],
                                  [1, 5, 1, 1, 1], [2, 5, 1, 1, 1], [3, 5, 1, 1, 1], [1, 6, 1, 1, 1], [2, 6, 1, 1, 1], [3, 6, 1, 1, 1]]
                  elsif (@media_type_to_convert.compartment == 48)
                    cup_layout = [[1, 1, 1, 1, 1], [2, 1, 1, 1, 1], [3, 1, 1, 1, 1], [4, 1, 1, 1, 1], [5, 1, 1, 1, 1], [6, 1, 1, 1, 1], [7, 1, 1, 1, 1], [8, 1, 1, 1, 1], [9, 1, 1, 1, 1], [10, 1, 1, 1, 1],
                                  [1, 2, 1, 1, 1], [2, 2, 1, 1, 1], [3, 2, 1, 1, 1], [4, 2, 1, 1, 1], [5, 2, 1, 1, 1], [6, 2, 1, 1, 1], [7, 2, 1, 1, 1], [8, 2, 1, 1, 1], [9, 2, 1, 1, 1], [10, 2, 1, 1, 1],
                                  [1, 3, 1, 1, 1], [2, 3, 1, 1, 1], [3, 3, 1, 1, 1], [4, 3, 1, 1, 1], [5, 3, 1, 1, 1], [6, 3, 1, 1, 1], [7, 3, 1, 1, 1], [8, 3, 1, 1, 1], [9, 3, 1, 1, 1], [10, 3, 1, 1, 1],
                                  [1, 4, 1, 1, 1], [2, 4, 1, 1, 1], [3, 4, 1, 1, 1], [4, 4, 1, 1, 1], [5, 4, 1, 1, 1], [6, 4, 1, 1, 1], [7, 4, 1, 1, 1], [8, 4, 1, 1, 1], [9, 4, 1, 1, 1], [10, 4, 1, 1, 1],
                                  [1, 1, 1, 1, 2], [2, 1, 1, 1, 2], [1, 2, 1, 1, 2], [2, 2, 1, 1, 2],
                                  [1, 1, 1, 1, 3], [2, 1, 1, 1, 3], [1, 2, 1, 1, 3], [2, 2, 1, 1, 3]]
                  else
                    cup_layout = [[ 1,1,2,1,1], [3,1,2,1,1],[5,1,2,1,1],
                                  [1,1,2,1,2], [3,1,2,1,2], [5,1,2,1,2],
                                  [1,1,1,1,3], [2,1,2,1,3], [4,1,2,1,3], [6,1,1,1,3]]
                  end
                  @kit.cups.sort.each_with_index do |cup,index|
                    cup.update_attributes(:cup_number => index+1, :cup_dimension => cup_layout[index].join(',') + ",#{cup.id}" ,:status => 1)
                  end
                  flash[:success] = "Changed Kit Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                  redirect_to :back
                else
                  flash[:error] = "Delete Cups/Parts from Cup to Convert Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                  redirect_to :back
                end
              end
            end
          else
            if @media_type_to_convert.kit_type == "binder"
              flash[:error] = "Cannot Convert Media Type to Binder"
              redirect_to :back
            elsif @media_type_to_convert.kit_type == "configurable"
              #CHANGE Media Type from Non-Configurable to Configurable
              config.logger.warn "{\"Msg\":\"Changing Kit Media Type for #{@kit.kit_number} from #{@current_kit_media_type.name} to #{@media_type_to_convert.name}.\"}" rescue ""
              if @kit.cups.count >= @media_type_to_convert.compartment
                # Changing From larger KitMediaType(Larger Kit) Cup Count to Smaller Configurable Kit ..............
                cup_count = @kit.cups.count - @media_type_to_convert.compartment
                @cups = @kit.cups.order("id asc").last(cup_count)
                @check_cup_part = Kitting::CupPart.where("cup_id IN (?) and status = ? ", @cups.map(&:id), 1)
                if @check_cup_part.empty?
                  @cups.each(&:destroy)
                  @kit.update_attribute("kit_media_type_id",@media_type_to_convert.id)
                  if (@media_type_to_convert.compartment == 18)
                    cup_layout = [[1, 1, 1, 1, 1], [2, 1, 1, 1 ,1], [3, 1, 1, 1 ,1], [1, 2, 1, 1, 1], [2, 2, 1, 1, 1], [3, 2, 1, 1, 1],
                                  [1, 3, 1, 1, 1], [2, 3, 1, 1, 1], [3, 3, 1, 1, 1], [1, 4, 1, 1, 1], [2, 4, 1, 1, 1], [3, 4, 1, 1, 1],
                                  [1, 5, 1, 1, 1], [2, 5, 1, 1, 1], [3, 5, 1, 1, 1], [1, 6, 1, 1, 1], [2, 6, 1, 1, 1], [3, 6, 1, 1, 1]]
                  elsif (@media_type_to_convert.compartment == 48)
                    cup_layout = [[1, 1, 1, 1, 1], [2, 1, 1, 1, 1], [3, 1, 1, 1, 1], [4, 1, 1, 1, 1], [5, 1, 1, 1, 1], [6, 1, 1, 1, 1], [7, 1, 1, 1, 1], [8, 1, 1, 1, 1], [9, 1, 1, 1, 1], [10, 1, 1, 1, 1],
                                  [1, 2, 1, 1, 1], [2, 2, 1, 1, 1], [3, 2, 1, 1, 1], [4, 2, 1, 1, 1], [5, 2, 1, 1, 1], [6, 2, 1, 1, 1], [7, 2, 1, 1, 1], [8, 2, 1, 1, 1], [9, 2, 1, 1, 1], [10, 2, 1, 1, 1],
                                  [1, 3, 1, 1, 1], [2, 3, 1, 1, 1], [3, 3, 1, 1, 1], [4, 3, 1, 1, 1], [5, 3, 1, 1, 1], [6, 3, 1, 1, 1], [7, 3, 1, 1, 1], [8, 3, 1, 1, 1], [9, 3, 1, 1, 1], [10, 3, 1, 1, 1],
                                  [1, 4, 1, 1, 1], [2, 4, 1, 1, 1], [3, 4, 1, 1, 1], [4, 4, 1, 1, 1], [5, 4, 1, 1, 1], [6, 4, 1, 1, 1], [7, 4, 1, 1, 1], [8, 4, 1, 1, 1], [9, 4, 1, 1, 1], [10, 4, 1, 1, 1],
                                  [1, 1, 1, 1, 2], [2, 1, 1, 1, 2], [1, 2, 1, 1, 2], [2, 2, 1, 1, 2],
                                  [1, 1, 1, 1, 3], [2, 1, 1, 1, 3], [1, 2, 1, 1, 3], [2, 2, 1, 1, 3]]
                  else
                    cup_layout = [[ 1,1,2,1,1], [3,1,2,1,1],[5,1,2,1,1],
                                  [1,1,2,1,2], [3,1,2,1,2], [5,1,2,1,2],
                                  [1,1,1,1,3], [2,1,2,1,3], [4,1,2,1,3], [6,1,1,1,3]]
                  end
                  @kit.cups.sort.each_with_index do |cup,index|
                    cup.update_attributes(:cup_number => index+1, :cup_dimension => cup_layout[index].join(',') + ",#{cup.id}" ,:status => 1)
                  end
                  flash[:success] ="Changed Kit Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                  redirect_to :back
                else
                  flash[:error] = "Delete Cups/Parts from Cup to Convert Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                  redirect_to :back
                end
              else
                # Changing From Lesser KitMediaType(Smaller Kit) Cup Count to Larger Configurable Kit   (UPGRADING ....)
                config.logger.warn "{\"Msg\":\"Changing Kit Media Type for #{@kit.kit_number} from #{@current_kit_media_type.name} to #{@media_type_to_convert.name}.\"}" rescue ""
                cup_count = @kit.cups.count
                cup_size = @media_type_to_convert.compartment - cup_count
                @kit.create_binder_cups(@kit,cup_count+cup_size,true,@kit.cups.count+1)
                if (@media_type_to_convert.compartment == 18)
                  cup_layout = [[1, 1, 1, 1, 1], [2, 1, 1, 1 ,1], [3, 1, 1, 1 ,1], [1, 2, 1, 1, 1], [2, 2, 1, 1, 1], [3, 2, 1, 1, 1],
                                [1, 3, 1, 1, 1], [2, 3, 1, 1, 1], [3, 3, 1, 1, 1], [1, 4, 1, 1, 1], [2, 4, 1, 1, 1], [3, 4, 1, 1, 1],
                                [1, 5, 1, 1, 1], [2, 5, 1, 1, 1], [3, 5, 1, 1, 1], [1, 6, 1, 1, 1], [2, 6, 1, 1, 1], [3, 6, 1, 1, 1]]
                elsif (@media_type_to_convert.compartment == 48)
                  cup_layout = [[1, 1, 1, 1, 1], [2, 1, 1, 1, 1], [3, 1, 1, 1, 1], [4, 1, 1, 1, 1], [5, 1, 1, 1, 1], [6, 1, 1, 1, 1], [7, 1, 1, 1, 1], [8, 1, 1, 1, 1], [9, 1, 1, 1, 1], [10, 1, 1, 1, 1],
                                [1, 2, 1, 1, 1], [2, 2, 1, 1, 1], [3, 2, 1, 1, 1], [4, 2, 1, 1, 1], [5, 2, 1, 1, 1], [6, 2, 1, 1, 1], [7, 2, 1, 1, 1], [8, 2, 1, 1, 1], [9, 2, 1, 1, 1], [10, 2, 1, 1, 1],
                                [1, 3, 1, 1, 1], [2, 3, 1, 1, 1], [3, 3, 1, 1, 1], [4, 3, 1, 1, 1], [5, 3, 1, 1, 1], [6, 3, 1, 1, 1], [7, 3, 1, 1, 1], [8, 3, 1, 1, 1], [9, 3, 1, 1, 1], [10, 3, 1, 1, 1],
                                [1, 4, 1, 1, 1], [2, 4, 1, 1, 1], [3, 4, 1, 1, 1], [4, 4, 1, 1, 1], [5, 4, 1, 1, 1], [6, 4, 1, 1, 1], [7, 4, 1, 1, 1], [8, 4, 1, 1, 1], [9, 4, 1, 1, 1], [10, 4, 1, 1, 1],
                                [1, 1, 1, 1, 2], [2, 1, 1, 1, 2], [1, 2, 1, 1, 2], [2, 2, 1, 1, 2],
                                [1, 1, 1, 1, 3], [2, 1, 1, 1, 3], [1, 2, 1, 1, 3], [2, 2, 1, 1, 3]]
                else
                  cup_layout = [[ 1,1,2,1,1], [3,1,2,1,1],[5,1,2,1,1],
                                [1,1,2,1,2], [3,1,2,1,2], [5,1,2,1,2],
                                [1,1,1,1,3], [2,1,2,1,3], [4,1,2,1,3], [6,1,1,1,3]]
                end
                @kit.cups.sort.each_with_index do |cup,index|
                  cup.update_attributes(:cup_dimension => cup_layout[index].join(',') + ",#{cup.id}" )
                end
                @kit.update_attribute("kit_media_type_id",@media_type_to_convert.id)
                flash[:success] ="Changed Kit Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                redirect_to :back
              end
            else
              # DOWNGRADING ..............
              config.logger.warn "{\"Msg\":\"Changing Kit Media Type for #{@kit.kit_number} from #{@current_kit_media_type.name} to #{@media_type_to_convert.name}.\"}" rescue ""
              if @kit.cups.count >= @media_type_to_convert.compartment
                cup_count = @kit.cups.count - @media_type_to_convert.compartment
                @cups = @kit.cups.order("id asc").last(cup_count)
                @check_cup_part = Kitting::CupPart.where("cup_id IN (?) and status = ? ", @cups.map(&:id), 1)
                if @check_cup_part.empty?
                  @cups.each(&:destroy)
                  @kit.update_attribute("kit_media_type_id",@media_type_to_convert.id)
                  @kit.cups.sort.each_with_index do |cup,index|
                    cup.update_attribute("cup_number",index+1)
                  end
                  flash[:success] ="Changed Kit Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                  redirect_to :back
                else
                  flash[:error] = "Delete Cups/Parts from Cup to Convert Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                  redirect_to :back
                end
              else
                # KIT MEDIA TYPE HAVING CUP LESSER THAN THE ORIGINAL KIT MEDIA TYPE   (UPGRADING ....)
                config.logger.warn "{\"Msg\":\"Changing Kit Media Type for #{@kit.kit_number} from #{@current_kit_media_type.name} to #{@media_type_to_convert.name}.\"}" rescue ""
                cup_size = @media_type_to_convert.compartment - @kit.cups.count
                @kit.create_binder_cups(@kit,cup_size,true)
                @kit.update_attribute("kit_media_type_id",@media_type_to_convert.id)
                @kit.cups.sort.each_with_index do |cup,index|
                  cup.update_attribute("cup_number",index+1)
                end
                flash[:success] = "Changed Kit Media Type from #{@current_kit_media_type.name} to #{@media_type_to_convert.name} ."
                redirect_to :back
              end
            end
          end
        end
        #end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # Checks for a Duplicate Kit Media Type , in order not to allow user to edit KMT of a KIT which is Under Edit Mode
    ##
    def search_duplicate
      if request.xhr?
        if params[:media_type_name] == 'Multiple Media Type'
          if can?(:>=, "6")
            @kmt = Kitting::KitMediaType.find_by_name(params[:media_type_name])
          else
            @kmt = nil
          end
        else
          @kmt = Kitting::KitMediaType.find(params[:media_type_id])
        end

        if @kmt.present?
          if Kitting::KitMediaType.where("customer_number = ?", current_user).map(&:name).include?(@kmt.name)
            render :json => {:status => false, :kmt => @kmt.name, :authorized => true }
          else
            render :json => {:status => true, :kmt => @kmt.name, :authorized => true }
          end
        else
          render :json => { :authorized => false }
        end

      end
    end

    private

    ##
    # Find system generated Configurable media type.
    ##
    def conf_media_type
      @conf_kit_media_types = Kitting::KitMediaType.where(:kit_type => "configurable",:customer_number => "SYSTEM")
    end
  end
end