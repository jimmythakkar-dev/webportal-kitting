module Kitting
	module KitsHelper
		require 'barby'
		require 'barby/barcode/code_93'
		require 'barby/barcode/code_39'
		require 'barby/outputter/png_outputter'


		def check_bailment_status(kit_number,version)
			@kit = Kitting::Kit.find_by_kit_number_and_commit_id(kit_number,nil)
			if @kit
				@updated_by = Kitting::Customer.find(@kit.updated_by).user_name  rescue ""
			else
				@updated_by = ""
			end
			bailment_info = invoke_webservice method: "get", action: "bailmentInfo", query_string: {custNo: current_user,partNo: kit_number,approverName:session[:user_name],level:session[:user_level],userName:@updated_by,versionNo:version,mailFlag:"Y"}
			bailment_info.present? ? bailment_info["boxId"].reject(&:empty?).present? ? true : false : false
		end

		def get_all_media_types
			Kitting::KitMediaType.find(:all)
		end

		def get_parts cup
			commited_cup_parts = cup.cup_parts.where(:commit_status => true,:status => true)
			commited_cup_parts.collect! do |cup_part|
				"<li class=#{cup_part.in_contract ? '' : 'non-contract-part'}>#{cup_part.part.part_number}(#{cup_part.demand_quantity})</li>
        #{commited_cup_parts.size == 1 ? "<div class='cup_img #{cup_part.in_contract ? '' : 'non-contract-part-image'}'>#{image_tag ( Rails.env == "production" || Rails.env == "qa" ) ? image_parts_url(:image =>cup_part.part.image_name.medium.to_s, class: "img-responsive" ).gsub("http://","https://") : image_parts_url(:image =>cup_part.part.image_name.medium.to_s), class: "img-responsive" ,:alt => "Image Not Available"}</div>" : ""}" if cup_part.status
			end
		end

		def get_drafted_cup_parts cup, pop_up = false
			orig_hash =Hash.new
			dup_hash =Hash.new
			cup.cup_parts.where(:commit_id => nil).map { |cp| orig_hash[cp.id]= cp.commit_id }
			cup.cup_parts.where(cup.cup_parts.arel_table[:commit_id].not_eq(nil)).map { |cp| dup_hash[cp.id]= cp.commit_id }
			orig_hash.merge!(dup_hash.invert)
			valid_hash = orig_hash.inject({}) { |h, (k, v)| h[k] = k if v.nil?; h }
			cup_ids = orig_hash.merge(valid_hash).values
			image = Kitting::CupPart.find( cup_ids).map(&:status).reject { |status| status == false }
			if pop_up
				cup_ids.collect! do |cup_part|
					cup_part = Kitting::CupPart.find(cup_part)
					if cup_part.status
						"<li class='clearfix'><div class='popup_thumbnail thumbnail clearfix'> #{image_tag ( Rails.env == "production" || Rails.env == "qa" ) ? image_parts_url(:image =>Kitting::CupPart.find(cup_part).part.image_name.medium.to_s).gsub("http://","https://") : image_parts_url(:image =>Kitting::CupPart.find(cup_part).part.image_name.medium.to_s),class: 'popup-part-thumbnail img-responsive',:alt => "Image Not Available" }" +
								"<div class='popup_caption caption' class='pull-left'>#{"<span class='text-error non_c_part_in_popup_text'> Non-Contract Part</span>".html_safe unless cup_part.in_contract }<h5 class='part_number'><b><span>#{ cup_part.part.part_number }</span></b></h5><div class='part_name'>#{truncate(cup_part.part.name, length: 18, separator: '...')}</div>"+
								"<b>Quantity: </b><div class='part_qty_n_uom'>#{ text_field_tag :quantity, cup_part.demand_quantity , :class => 'form-control demand_quantities',style: 'width: 65px', :required => true, :maxlength => '4', :disabled => true } <span class='uom'><b>#{ cup_part.uom}</b></span></div>"+
								"<a class='btn btn-default pull-left #{cup_part.in_contract && cup_part.demand_quantity != "WL" ? 'edit_popup_part_qty': "#{cup_part.in_contract ? 'wl_edit_popup_part_qty' : 'non_edit_popup_part_qty' }" }'><span class='glyphicon glyphicon-edit'></span></a>  #{ link_to "<span class='glyphicon glyphicon-remove'></span>".html_safe , delete_record_kits_path(part_number: cup_part.part.part_number,cup_id: cup_part.cup.id, kit_id: cup_part.cup.kit.id), method: 'POST', class: 'btn btn-danger pull-right remove_part', remote: true}</div></div>"+
								"</li>"
					end
				end

			else
				cup_ids.collect! do |cup_part|
					"<li>#{Kitting::CupPart.find(cup_part).part.part_number}(#{Kitting::CupPart.find(cup_part).demand_quantity})</li>
       #{(image.count == 1 or image.count == 0) ? "<div class='cup_img'>#{image_tag ( Rails.env == "production" || Rails.env == "qa" ) ? image_parts_url(:image =>Kitting::CupPart.find(cup_part).part.image_name.medium.to_s).gsub("http://","https://") : image_parts_url(:image =>Kitting::CupPart.find(cup_part).part.image_name.medium.to_s),class: "img-responsive",:alt => "Image Not Available" }</div>" : ""}" if Kitting::CupPart.find(cup_part).status
				end
			end
		end

		def get_drafted_binder_cup_parts cup
			orig_hash =Hash.new
			dup_hash =Hash.new
			cup.cup_parts.where(:commit_id => nil).map { |cp| orig_hash[cp.id]= cp.commit_id }
			cup.cup_parts.where(cup.cup_parts.arel_table[:commit_id].not_eq(nil)).map { |cp| dup_hash[cp.id]= cp.commit_id }
			orig_hash.merge!(dup_hash.invert)
			valid_hash = orig_hash.inject({}) { |h, (k, v)| h[k] = k if v.nil?; h }
			cup_ids = orig_hash.merge(valid_hash).values
		end

		def get_parts_with_qty(cup)
			if cup.cup_parts.present?
				cup.cup_parts.where(:commit_status => true,:status => true).collect! do |cup_part|
					#"<li style=\"font-size: 100%; font-style: normal;\">#{cup_part.part.part_number} QTY: #{cup_part.demand_quantity} </li>" if cup_part.status
          "<li style=\"font-size: 100%; font-style: normal; padding-left:5px; \">
          #{cup_part.part.part_number} (QTY: #{cup_part.demand_quantity})</br>#{!cup_part.in_contract ? "<br><span>* Not Provided by KLX</span><br>" : ""}  #{ image_tag(cup_part.part.image_name.medium, height: '70', width: '130') if cup_part.part.image_name.to_s != "#{Rails.root}/public/image_not_available.jpg" && cup.cup_parts.where(:commit_status => true,:status => true).size == 1}</li>" if cup_part.status
				end
			else
				["<li style=\"font-size: 100%; font-style: normal;\"></li>"]
			end

		end

		def get_filled_parts cup, kit_fillings_id
			cup.cup_parts.collect! do |cup_part|
				"<li>#{cup_part.part.part_number}<span>(#{cup_part.demand_quantity})</span>
      <div>(#{get_filled_quantity cup_part.id, kit_fillings_id})</div></li>" if cup_part.status
			end
		end

		def get_commited_parts cup, kit_fillings_id
			commited_cup_parts = cup.cup_parts.where(:commit_status => true,:status => true)
			commited_cup_parts.collect! do |cup_part|
				"<li><span #{cup_part.in_contract ? "class='part_block'" : "class='part_block non-contract-part'"}>#{cup_part.part.part_number}</span><span>(#{cup_part.demand_quantity})</span>
      #{cup_part.in_contract ? "<div>(#{ get_filled_quantity cup_part.id, kit_fillings_id })</div>" : "" }
        </li>
       #{commited_cup_parts.size == 1 ? "<div class='cup_img'>#{image_tag ( Rails.env == "production" || Rails.env == "qa" ) ? image_parts_url(:image =>cup_part.part.image_name.medium.to_s).gsub("http://","https://") : image_parts_url(:image =>cup_part.part.image_name.medium.to_s),class: "img-responsive",:alt => "Image Not Available"}</div>":""}".html_safe if cup_part.status
			end
		end

		def get_filled_quantity cup_part_id, kit_filling_id
			Kitting::KitFillingDetail.find_by_cup_part_id_and_kit_filling_id(cup_part_id,kit_filling_id).filled_quantity#(kit_fillings_id).kit_filling_details.where('cup_part_id = ?', cup_part_id).first.filled_quantity
		rescue
			""
		end

		def get_turn_count cup_part_id, kit_fillings_id
			Kitting::KitFilling.find(kit_fillings_id).kit_filling_details.where('cup_part_id = ?', cup_part_id).first.turn_count
		rescue
			0
		end

		def get_cups_layout cups, compartments_layout
			cups = cups.sort_by { |cup| cup.cup_number } rescue cups.sort
			new_cups = []
			compartment_layout = get_compartments_layout compartments_layout
			k = 0
			for i in 0...compartment_layout.length do
				new_cups[i] = []
				for j in 0...compartment_layout[i] do
					new_cups[i] << cups[k]
					k = k + 1
				end
			end
			new_cups
		end

		def get_compartments_layout compartments_layout
			JSON.parse(compartments_layout).values.collect! {|value| value.to_i}
		rescue => e
			[]
		end

		def get_cups_layout_for_cardex_kit cups, compartments_layout
			cups = cups.sort { |x,y| x[0].to_i <=> y[0].to_i }
			new_cups = []
			compartment_layout = get_compartments_layout_for_cardex_kit compartments_layout
			k = 0
			for i in 0...compartment_layout.length do
				new_cups[i] = []
				for j in 0...compartment_layout[i] do
					new_cups[i] << cups[k]
					k = k + 1
				end
			end
			new_cups
		end

		def get_compartments_layout_for_cardex_kit compartments_layout

			JSON.parse(compartments_layout).values.collect! {|value| value.to_i}

		rescue => e
			[]
		end

		def generate_barcode part_number
			barcode = Barby::Code39.new(part_number, true)
			Barby::Code39::EXTENDED_ENCODINGS["/"]="/"
			File.open(APP_CONFIG['kitting_barcode_path']+part_number.split('').map(&:ord).join("")+'.png', 'w'){|f|
				f.write barcode.to_png(:margin => 3, :xdim => 1, :height => 25)
			}
		end

		def generate_barcode_for_kit_number kit_number
			barcode = Barby::Code39.new(kit_number, true)
			Barby::Code39::EXTENDED_ENCODINGS["/"]="/"
			File.open(APP_CONFIG['kitting_barcode_path']+kit_number.split('').map(&:ord).join("")+'.png', 'w'){|f|
				f.write barcode.to_png(:margin => 5, :xdim => 1, :height => 35)
			}
		end

		# def generate_barcode_for_all_in_one kit_number
		# 	barcode = Barby::Code93.new(kit_number)
    #
		# 	if kit_number.size < 19
		# 		File.open(APP_CONFIG['kitting_barcode_path']+kit_number.split('').map(&:ord).join("")+'.png', 'w'){|f|
		# 			f.write barcode.to_png(:margin=>0,:xdim=>1,:height => 25)
		# 		}
		# 	else
		# 		File.open(APP_CONFIG['kitting_barcode_path']+kit_number.split('').map(&:ord).join("")+'.png', 'w'){|f|
		# 			f.write barcode.to_png(:margin=>0,:xdim=>1,:height => 17)
		# 		}
		# 	end
    #
		# end

		def generate_barcode_for_all_in_one kit_number, xdim = 1, height = 25
			barcode = Barby::Code93.new(kit_number)

			if kit_number.size < 19
				File.open(APP_CONFIG['kitting_barcode_path']+kit_number.split('').map(&:ord).join("")+'.png', 'w'){|f|
					f.write barcode.to_png(:margin=>0,:xdim=>xdim,:height => height)
				}
			else
				File.open(APP_CONFIG['kitting_barcode_path']+kit_number.split('').map(&:ord).join("")+'.png', 'w'){|f|
					f.write barcode.to_png(:margin=>0,:xdim=>1,:height => 17)
				}
			end

		end



		def get_parts_for_print_label cup
			cup.cup_parts.where(:commit_status => true).collect! do |cup_part|
        "<li>#{!cup_part.in_contract ? "<span>* Not Provided by KLX</span>" : ""}
        <div style='width:50%; float:left; vertical-align:center'>#{cup_part.part.part_number}&nbsp; <br/> Qty:&nbsp;#{cup_part.demand_quantity} </div><div style='width:50%; float:left'> #{ image_tag(cup_part.part.image_name.medium, height: '150', width: '150') if cup_part.part.image_name.to_s != "#{Rails.root}/public/image_not_available.jpg" && cup.cup_parts.size == 1}</div></li>" if cup_part.status
			end
		end

		def get_kit_with_path kit_number
			Kitting::Kit.find_by_kit_number_and_commit_id(kit_number,nil).nil? ? kit_path(CGI.escape(kit_number)) : kit_path(Kit.find_by_kit_number_and_commit_id(kit_number,nil).id)
			# orig_kit = Kitting::Kit.find_by_kit_number_and_commit_id(kit_number,nil)
			# dup_kit = Kitting::Kit.find_by_kit_number_and_commit_id(kit_number,orig_kit.id) if orig_kit.present?
			# orig_kit.nil? ? kit_path(CGI.escape(kit_number)) : dup_kit.present? ? kit_path(dup_kit.id): kit_path(orig_kit.id)
		end
		def get_kit_id kit
			Kitting::Kit.find_by_kit_number(kit).nil? ? nil : Kit.find_by_kit_number(kit)
		end
		def check_kit_filling kit
			Kitting::KitFilling.where('kit_copy_id = ? and flag= ? ', kit, true).blank? ? false : true
		end
		def get_filling_id kit
			fill_id = Kitting::KitFilling.where('kit_copy_id = ? and flag= ? ', kit, true)
			if !fill_id.blank?
				fill_id
			else
				false
			end
		end
		def check_kit_receiving kit_copy
			Kitting::KitFilling.where('kit_copy_id = ? and flag = ? ', kit_copy, false).blank? ? false : true
		end

		def display_status(status)
			if status == 1 || status == '1'
				return "ACTIVE"
			elsif status == 2 || status == '2'
				return "PENDING"
			elsif status == 6 || status == '6'
				return "INACTIVE"
			end
		end

		def get_configurable_drafted_cup_parts cup
			orig_hash =Hash.new
			dup_hash =Hash.new
			cup.cup_parts.where(:commit_id => nil).map { |cp| orig_hash[cp.id]= cp.commit_id }
			cup.cup_parts.where(cup.cup_parts.arel_table[:commit_id].not_eq(nil)).map { |cp| dup_hash[cp.id]= cp.commit_id }
			orig_hash.merge!(dup_hash.invert)
			valid_hash = orig_hash.inject({}) { |h, (k, v)| h[k] = k if v.nil?; h }
			cup_ids = orig_hash.merge(valid_hash).values
			image = Kitting::CupPart.find( cup_ids).map(&:status).reject { |status| status == false }
			cup_ids.collect! do |cup_part|
				"<span #{Kitting::CupPart.find(cup_part).in_contract ? "class='part_block'" : "class='part_block non-contract-part'"}>#{Kitting::CupPart.find(cup_part).part.part_number}(#{Kitting::CupPart.find(cup_part).demand_quantity})</span>
        #{(image.count == 1 or image.count == 0) ? "<div #{Kitting::CupPart.find(cup_part).in_contract ? '' : "class='cup_img non-contract-part-image img-responsive'"}>#{image_tag ( Rails.env == "production" || Rails.env == "qa" ) ? image_parts_url(:image =>Kitting::CupPart.find(cup_part).part.image_name.medium.to_s).gsub("http://","https://") : image_parts_url(:image =>Kitting::CupPart.find(cup_part).part.image_name.medium.to_s),style: "width:100px; height:auto",:alt => "Image Not Available" }</div>" : ""}" if Kitting::CupPart.find(cup_part).status
			end
		end

		def get_configurable_part_with_qty cup
			commited_cup_parts = cup.cup_parts.where(:commit_status => true,:status => true)
			commited_cup_parts.collect! do |cup_part|
				"<span #{cup_part.in_contract ? "class='part_block'" : "class='part_block non-contract-part'"} > #{cup_part.part.part_number} (#{cup_part.demand_quantity})</span>
        #{commited_cup_parts.size == 1 ? "<div #{cup_part.in_contract ? '' : "class='cup_img non-contract-part-image'"} >#{image_tag ( Rails.env == "production" || Rails.env == "qa" ) ? image_parts_url(:image =>cup_part.part.image_name.medium.to_s).gsub("http://","https://") : image_parts_url(:image =>cup_part.part.image_name.medium.to_s), style: "width:100px; height:auto",:alt => "Image Not Available"}</div>":""}"
			end
		end

		def print_configurable_part_with_qty cup
			commited_cup_parts = cup.cup_parts.where(:commit_status => true,:status => true)
			commited_cup_parts.collect! do |cup_part|
				"<span class='part_block #{cup_part.part.part_number.size + cup_part.demand_quantity.size > 15 ? 'large_part_number' : ''} '> #{cup_part.part.part_number} (#{cup_part.demand_quantity})</span>
        #{ image_tag(cup_part.part.image_name.medium, height: 'auto', width: '100px') if cup_part.part.image_name.to_s != "#{Rails.root}/public/image_not_available.jpg" && commited_cup_parts.size == 1}
				#{!cup_part.in_contract ? "<span class='config-non-contract-part'>* Not Provided by KLX</span>" : ""}"
			end
		end

		def get_config_part_filled_qty cup, kit_fillings_id
			commited_cup_parts = cup.cup_parts.where(:commit_status => true,:status => true)
			commited_cup_parts.collect! do |cup_part|
				"<span #{cup_part.in_contract ? "class='part_block'" : "class='part_block non-contract-part'"}>#{cup_part.part.part_number} </span>
        <span>(#{ cup_part.demand_quantity})</span>
        #{cup_part.in_contract ? "<div>(#{ get_filled_quantity cup_part.id, kit_fillings_id })</div>" : "" }
				#{commited_cup_parts.size == 1 ? "<div class='cup_img'>#{image_tag ( Rails.env == "production" || Rails.env == "qa" ) ? image_parts_url(:image =>cup_part.part.image_name.medium.to_s).gsub("http://","https://") : image_parts_url(:image =>cup_part.part.image_name.medium.to_s), style: "width:100px; height:auto",:alt => "Image Not Available"}</div>":""}".html_safe if cup_part.status
			end
		end

    def binder_part_input(count,action,options={})
      html_out = 2.enum_for(:times).collect do |time|
        case time
          when 0
            content_tag :div,:class => "row" do
              result = 4.enum_for(:times).collect do |count_label|
                case count_label
                  when 0
                    content_tag :div,:class => "col-sm-4" do
                      content_tag(:label,"Part Number")
                    end
                  when 1
                    content_tag :div,:class => "col-sm-3" do
                      content_tag(:label,"Part Name")
                    end
                  when 2
                    content_tag :div,:class => "col-sm-2" do
                      content_tag(:label,"QTY")
                    end
                  when 3
                    content_tag :div,:class => "col-sm-3" do
                      content_tag(:label,"UOM")
                    end
                end
              end
              result.join(" ").html_safe
            end
          when 1
            content_tag :div,:class => "row" do
              result = 4.enum_for(:times).collect do |count_id|
                case count_id
                  when 0
                    content_tag :div,:class => "col-sm-4" do
                      if action == "edit"
                        text_field_tag "edit_part_number_auto_#{count}", options[:part_no] , :class => "form-control autofillparts edit_binder_part_number_auto", :required => true,:autocomplete => :off, :disabled => true
                      else
                        text_field_tag "part_number_auto_#{count}", nil , :class => "form-control autofillparts binder_part_number_auto", :required => true,:autocomplete => :off
                      end
                    end
                  when 1
                    if action == "edit"
                      content_tag :div,:class => "col-sm-3" do
                        text_field_tag("edit_part_name_#{count}", options[:name] , :class => "form-control", :disabled => true)
                      end
                    else
                      content_tag :div,:class => "col-sm-3" do
                        text_field_tag("part_name_#{count}", nil , :class => "form-control", :disabled => true) +  hidden_field_tag(:part_list,"")
                      end
                    end
                  when 2
                    if action == "edit"
                      content_tag :div,:class => "col-sm-2" do
                        text_field_tag "edit_demand_quantity_#{count}", options[:qty] , :class => "form-control demand_quantities", :required => true, :maxlength => "4", :disabled => true
                      end
                    else
                      content_tag :div,:class => "col-sm-2" do
                        text_field_tag "demand_quantity_#{count}", nil , :class => "form-control demand_quantities", :required => true, :maxlength => "4"
                      end
                    end
                  when 3
                    if action == "edit"
                      content_tag :div,:class => "col-sm-3" do
                        text_field_tag "edit_uom_#{count}", options[:uom] , :class => "form-control binder_uom", :disabled => true
                        #select_tag "uom_#{count}", options_for_select([["EA","EA"],["LB","LB"],["HU","HU"], ["TH","TH"]], :selected=>options[:uom]), {:class => 'input-small binder_uom'}, :disabled => true
                      end
                    else
                      content_tag :div,:class => "col-sm-3" do
                        select_tag "uom_#{count}", options_for_select([["EA","EA"],["LB","LB"],["HU","HU"], ["TH","TH"]]), {:class => 'form-control binder_uom'}
                      end
                    end
                end
              end
              result.join(" ").html_safe
            end
        end
      end
      html_out.join(" ").html_safe
    end
	end
end
