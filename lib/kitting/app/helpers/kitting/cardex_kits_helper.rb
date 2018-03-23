module Kitting
  module CardexKitsHelper

    def get_bom_detail(kit)
      @cardex_data = invoke_webservice method: 'get', action: 'kitCompInfo',query_string: {kitPartNo: params[:kit_number]}
      # @cardex_data = {"kitCompPartNo"=>["AN3-7","AN3-7A","AN3-4A","AN3-5A","AN3H4A","AS21919WCH06","AS5174D1212","AS5178J12","M83413/8-A005BB","M83413/8-A008BB","MS21042L3","MS27039-1-16","MS27039C1-12","MS28778-12","NAS1149C1790R","NAS1149D0316K","NAS43DD3-35N","NAS43HT3-24"],
      #                 "kcpnQty"=>["200","100","7","8","4","4","2","2","2","2","6","6","4","2","4","16","6","4"],"kcpnUom"=>["EA","EA","EA","EA","EA","EA","EA","EA","EA","EA","EA","EA","EA","EA","EA","EA","EA"]}
      @oracle_data = Kitting::CardexKit.find_by_kit_number(params[:kit_number])

      cardex_parts = @cardex_data["kitCompPartNo"]
      cardex_qty = @cardex_data["kcpnQty"]

      oracle_parts = Array.new
      oracle_qty = Array.new
      @parts_not_in_cardex = Array.new
      @parts_not_in_oracle = Array.new

      JSON[@oracle_data.kit_html_layout].each do |kit_box|
        kit_box.each do |li|
          li.second.split(",")[5].split("#").each { |l| oracle_parts << l.gsub(/\W[(]\d*[)]/,"") } if li[1].split(",")[5]
          li.second.split(",")[5].split("#").each { |l| oracle_qty << l.split(" ").last.gsub(/\D/,"") } if li[1].split(",")[5]
          oracle_parts = oracle_parts.flatten
          oracle_qty = oracle_qty.flatten
        end
      end


      @parts_not_in_cardex = @cardex_data["kitCompPartNo"] - oracle_parts
      @parts_not_in_oracle = oracle_parts - @cardex_data["kitCompPartNo"]

    end

    def display_part_difference c_parts, o_parts
      str = ""
      if c_parts.size > 0 || o_parts.size > 0
        str = "#{image_seperator}<div class=\"row\"><div class=\"col-sm-12\">"
        if c_parts.size > 0
          str += "<div class='text-info'>Added Parts : #{c_parts.join(",")} </div>"
        end
        if o_parts.size > 0
          str += "<div class='text-danger'> Removed Parts : #{o_parts.join(",")}</div></div></div>"
        end
      end
      str.html_safe
    end

    # def get_media_type_wise_layout media_type_name
    #   case media_type_name
    #     when "Multiple Media Type"
    #       path = ""
    #     when "8 Dividable Small Tub"
    #       path = ""
    #     when "16 Dividable Medium Tub"
    #       path = ""
    #     when "24 Dividable Medium Tub"
    #       path = ""
    #     when "8 RTB Tacklebox"
    #       path = ""
    #     when "24 RTB Tacklebox"
    #       path = ""
    #     when "Small Removable Cup TB"
    #       path =
    #     when "Large Removable Cup TB"
    #       path = ""
    #     when "Small Configurable TB"
    #       path = ""
    #
    #
    #     else
    #       return ""
    #   end
    #
    #   complete_path = link_to media_type_name,
    # end
    def fetch_cup_layout kit_media_type
      if kit_media_type.kit_type == "configurable"
        if kit_media_type.name == "Small Removable Cup TB"
          cup_layout = [{"1"=>"1,1,1,1,1","2"=>"1,2,1,1,1","3"=>"1,3,1,1,1","4"=>"2,1,1,1,1","5"=>"2,2,1,1,1",
                         "6"=>"2,3,1,1,1","7"=>"3,1,1,1,1","8"=>"3,2,1,1,1","9"=>"3,3,1,1,1","10"=>"4,1,1,1,1",
                         "11"=>"4,2,1,1,1","12"=>"4,3,1,1,1","13"=>"5,1,1,1,1","14"=>"5,2,1,1,1","15"=>"5,3,1,1,1",
                         "16"=>"6,1,1,1,1","17"=>"6,2,1,1,1","18"=>"6,3,1,1,1"},{},{}].to_json
        elsif kit_media_type.name == "Large Removable Cup TB"
          cup_layout =[{"1"=>"1,1,1,1,1","2"=>"1,2,1,1,1","3"=>"1,3,1,1,1","4"=>"1,4,1,1,1","5"=>"1,5,1,1,1","6"=>"1,6,1,1,1","7"=>"1,7,1,1,1",
                        "8"=>"1,8,1,1,1","9"=>"1,9,1,1,1","10"=>"1,10,1,1,1","11"=>"2,1,1,1,1","12"=>"2,2,1,1,1","13"=>"2,3,1,1,1","14"=>"2,4,1,1,1",
                        "15"=>"2,5,1,1,1","16"=>"2,6,1,1,1","17"=>"2,7,1,1,1","18"=>"2,8,1,1,1","19"=>"2,9,1,1,1","20"=>"2,10,1,1,1","21"=>"3,1,1,1,1",
                        "22"=>"3,2,1,1,1","23"=>"3,3,1,1,1","24"=>"3,4,1,1,1","25"=>"3,5,1,1,1","26"=>"3,6,1,1,1","27"=>"3,7,1,1,1","28"=>"3,8,1,1,1",
                        "29"=>"3,9,1,1,1","30"=>"3,10,1,1,1","31"=>"4,1,1,1,1","32"=>"4,2,1,1,1","33"=>"4,3,1,1,1","34"=>"4,4,1,1,1","35"=>"4,5,1,1,1",
                        "36"=>"4,6,1,1,1","37"=>"4,7,1,1,1","38"=>"4,8,1,1,1","39"=>"4,9,1,1,1","40"=>"4,10,1,1,1"},{"41"=>"1,1,1,1,2","42"=>"1,2,1,1,2",
                                                                                                                     "43"=>"2,1,1,1,2","44"=>"2,2,1,1,2"},{"45"=>"1,1,1,1,3","46"=>"1,2,1,1,3","47"=>"2,1,1,1,3","48"=>"2,2,1,1,3"}].to_json
        elsif kit_media_type.name == "Small Configurable TB"
          cup_layout = [[[1,1,2,1],[3,1,2,1],[5,1,2,1]],
                        [[1,1,2,1],[3,1,2,1],[5,1,2,1]],
                        [[1,1,1,1],[2,1,2,1],[4,1,2,1],[6,1,1,1]]]
        end
      else
        cup_layout = get_non_config_layout Kitting::KitMediaType.find_by_id(kit_media_type).compartment_layout
      end
    end

    def get_non_config_layout compartments_layout
      compartment_layout = get_layout compartments_layout
      index = 0
      h = {}
      for i in 0...compartment_layout.length do
        k = 0
        for j in 0...compartment_layout[i] do
          array_val = [i + 1,k + 1 ]
          h.merge!((index + 1).to_s => array_val.join(","))
          k = k + 1
          index = index + 1
        end
      end
      h.to_json
    end

    def get_layout compartments_layout
      JSON.parse(compartments_layout).values.collect! {|value| value.to_i}
    rescue => e
      []
    end

    def get_empty_kits json
      junk_values = get_junk_value json
      status_array = Array.new
      kit_array = Array.new
      junk_values.each do  |data|
        data.flatten.map { |data|
          status_array << data.split(",").last if data.split(",").last =~ /\(\d+\)/
        }
        kit_array << status_array
        status_array = Array.new
      end
      return kit_array
    end

    def get_used_parts json
      junk_values = get_junk_value json
      used_values = Array.new
      junk_values.flatten.map { |data|
        used_values << data.split(",").last if data.split(",").last =~ /\(\d+\)/
      }
      return used_values
    end

    def get_junk_value json
      junk_values = Array.new
      json.each do |js|
        if JSON.parse(js).is_a?(Hash)
          junk_values << JSON.parse(js).values
        else
          junk_values << JSON.parse(js).map(&:values)
        end
      end
      return junk_values
    end
  end
end