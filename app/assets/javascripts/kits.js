// CODE CHANGE TO MERGE v1.15c
$('.dropdown-toggle').dropdown();
$('ul.dropdown-menu li a').click(function (e) {
    var $div = $(this).parent().parent().parent();
    var $btn = $div.find('button');
    $btn.html($(this).text() + ' <span class="caret"></span>');
    $div.removeClass('open');
    $("#kit_search_type").val($(this).attr("val"))
    e.preventDefault();
    return false;
});
$("#bailment").each(function(index) {
    $("#bailment")[index].click();
});
$("#submit_selected").click(function(){
    var cups_checked = $("#select_ids_:checked").length;
    if (cups_checked == 0) {
        $.msgBox({
            title:"Print Selected Compartments",
            content:"Please select atleast one compartment for printing pick ticket.",
            type:"info"
        });
        return false;
    }
    else if($("#kit_media_type").val() == "Multiple Media Type"){
        setTimeout(function(){
            $("#select_ids_:checked").removeAttr('checked');
        }, 2000);
    }
    return true;
});
$("#approve_selected").click(function(){
    var kits_checked = $("#status_:checked").length;
    if (kits_checked == 0)
    {
        alert ("Please select at least one kit");
        return false;
    }
    return true;
});
$("#filter_location_id").change(function(){
    $(location).attr('href',"/kitting/kits?location="+$(this).val());
});

$("#kit_bincenter").blur(function(){
    if($("#kit_bincenter").val() != ""){

        var cust_id = $("#cust_id").val()
        var kit_id = $("#kit_id").val()
        var part_num = 'KIT-'+cust_id+'-'+kit_id
        $("#kit_kit_number").val(part_num)
        $("#kit_kit_number").attr('readonly','true');
    }
});

$("#alternate-bin").click(function() {
    var selected_ids = [];
    var sort_by = $('input[name="sort_by"]:checked').val();
    if($("#select_ids_:checked").length > 0){
        $(':checkbox:checked').each(function(i){
            selected_ids[i] = $(this).val();
        });
    }
    $("#select_ids_for_alternate_").val(selected_ids)
    $("#sort_by").val(sort_by)
    $('#bincenter_select_modal').modal({"backdrop": "static"});
    return false;
});
$(".disabled_box").click(function(event){
    $.msgBox({
        title:"Data Not Found",
        content:"Kit which you are trying to approve is not present in cardex, kindly upload the kit to cardex and then approve !!!"
    });
});
$(".kit_desc,.kit_notes,.bincenter,.part_bincenter").blur(function(event){
    var curr_id= $(this);
    $(this).addClass('loadinggif');
    $.ajax({
        type: "POST",
        url: "/kitting/kits/update_kit_details",
        data: { kit_id: $("#kit_id").val(), description: $("#description").val(),notes: $("#notes").val(),bincenter:$("#bincenter").val(),part_bincenter:$("#part_bincenter").val() },
        success: function(data) {
            if (data.status == "Success" ) {
            }
        },
        complete:function(){ curr_id.removeClass('loadinggif'); },
        dataType: 'json'
    });
});
$(".approve_kits").click(function(e){
    var val = $(this).attr("val");
    var selected_data = $(".part_bin_center[val="+val+"]");
    if(selected_data.val() == "")
    {
        $.msgBox({
            title:"PART BIN CENTER",
            content:"PLEASE SELECT A PART BIN CENTER FROM THE LIST AND APPROVE THE KIT."
        });
        return false;
    }
});

var non_contract_parts = $('li.non-contract-part').size();
if(non_contract_parts){
    $('li.non-contract-part').parent().parent().find('h5').find('div').addClass('non_contract_cup_number_label')
    $('li.non-contract-part').parent().parent().find('h5').find('div').removeClass('cup_number_label')
}
var filling_non_contract_parts = $('ul.filling_page li span.non-contract-part').size();
if(filling_non_contract_parts){
    $('li span.non-contract-part').parent().removeClass('empty_filled_quantity')
}

if($( ".multi_cup_parts").children().last().find("input[id='part_number_auto']").length > 0) {
    $("#part_remove_div").show();
}
$(".add_part_line").click(function(e){
    var part_row_number = (parseInt($('.multi_cup_parts').children().length)/2) + 1;
    var prevent_adding_new_part = part_row_number -1;
    var part_array = $(".part_numbers_auto").map(function() {
        if($(this).val() != ""){
            return $(this).val();
        }
    }).get();

    if (prevent_adding_new_part == 1){
        var part_number_input = "input[name='part_number_auto']";
        var demand_quantity_input = "input[name='demand_quantity']";
        $("#part_remove_div").show();
    }
    else{
        var part_number_input = "input[name='part_number_auto"+prevent_adding_new_part+"']";
        var demand_quantity_input = "input[name='demand_quantity"+prevent_adding_new_part+"']";
        for(var i=2;i<prevent_adding_new_part;i++){
            $('#part_remove_div'+i).show();
        }
//        $('#part_remove_div'+prevent_adding_new_part).show();
        $("#part_remove_div"+prevent_adding_new_part).css("display","block");
    }
    var current_part_number_value = $( ".multi_cup_parts").children().last().find(part_number_input).val();
    part_array.pop();
    var check_part = part_array.indexOf(current_part_number_value);
    if($( ".multi_cup_parts").children().last().find(demand_quantity_input).val() == "WL") {
        $.msgBox({
            title:"Alert",
            content: "Can't enter multiple parts as the quantity is WL",
            type: "info"
        });
        e.preventDefault();
    }
    else if(check_part > -1){
        var num = part_row_number-1;
        $(".part_div"+num).remove();
        num = num-1;
        $("#part_remove_div"+num).css("display","none");
        $.msgBox({
            title:"Alert",
            content: "Can't enter same parts in a single cup.",
            type: "info"
        });
        e.preventDefault();
    }
    else {
        $(".multi_cup_parts").append(
                "<div class='row part_div"+part_row_number+"' >" +
                "<div class='col-sm-3'>" +
                "Part Number<span class='alert_msg'>*</span>" +
                "</div>" +
                "<div class='col-sm-3'>" +
                'Part Name' +
                "</div>" +
                "<div class='col-sm-2'>" +
                "Quantity<span class='alert_msg'>*</span>" +
                "</div>" +
                "<div class='col-sm-2'>" +
                "UOM<span class='alert_msg'>*</span>" +
                "</div>" +
                "</div>" +
                "<div class='row part_div"+part_row_number+"'>" +
                "<div class='col-sm-3'>" +
                "<input autocomplete='off' class='form-control autofillparts part_numbers_auto' id='part_number_auto"+part_row_number+"' name='part_number_auto"+part_row_number+"' required='required' type='text'>" +
                "<input id='part_list"+part_row_number+"' name='part_list"+part_row_number+"' type='hidden' value=''>" +
                "</div>" +
                "<div class='col-sm-3'>" +
                "<input class='form-control' disabled='disabled' id='part_name"+part_row_number+"' name='part_name"+part_row_number+"' type='text'>" +
                "</div>" +
                "<div class='col-sm-2'>" +
                "<input class='form-control demand_quantities' id='demand_quantity"+part_row_number+"' maxlength='4' name='demand_quantity"+part_row_number+"' required='required' type='text'>" +
                "</div>" +
                "<div class='col-sm-2'>" +
                "<select class='form-control uoms' id='uom"+part_row_number+"' name='uom"+part_row_number+"'><option value='EA'>EA</option>" +
                "<option value='LB'>LB</option>" +
                "<option value='HU'>HU</option>" +
                "<option value='TH'>TH</option>" +
                "</select>" +
                "</div>" +
                "<div class='col-sm-2'>" +
                "<div class='row part-image"+part_row_number+"'>" +
                "<div class='col-sm-10'>" +
                "   </div>" +
                "</div>" +
                "</div>" +
                "<div class='col-sm-1' style='display: none' id='part_remove_div"+part_row_number+"'>" +
                "<a class='btn btn-danger btn-xs part_row_delete' id='remove_part"+part_row_number+"'><span  class='glyphicon glyphicon-remove'></span></a>" +
                "</div>" +
                "</div>"
        );
    }
    $('.part_numbers_auto').on("keypress paste",function (){
        if ($("#non_contract_part_check").is(':checked') == false){
            var current_part_id = this.id;
            var current_element_id = current_part_id.slice(-1);
            if($.isNumeric(current_element_id)){
                var current_part_list_id = '#part_list'+current_element_id;
            }
            else {
                var current_part_list_id = '#part_list'
            }
            var current_part_number = '#'+current_part_id;
            setTimeout(function () {
                if($(current_part_number).val().length >= 4) {
                    if($.active == 0 ) {
                        $.ajax({
                            url: "/kitting/kits/part_look_up",
                            type: 'POST',
                            data: { "part_number" : $(current_part_number).val() },
                            onLoading: show_spinner(),
                            success: function(data) {
                                hide_spinner();
                                if(data == null){
                                    alert("Service temporary unavailable, sorry for inconvenience");
                                    $('#loading').css('visibility','hidden');
                                    $(current_part_number).val("");
                                }
                                else {
                                    if (data.errMsg == "" && data.searchPartList != ""){
                                        var part_data = data.searchPartList;
                                        $(current_part_list_id).val(part_data);
                                        $("#add_cup_part, #add_and_next_cup_part").attr("disabled", false);
                                        if(part_data[0] == "")
                                        {
                                            alert("Part Number does not exists, please re-enter.");
                                            $(current_part_number).val("");
                                        }
                                        $(current_part_number).autocomplete({
                                            source: function(req, responseFn) {
                                                var re = $.ui.autocomplete.escapeRegex(req.term);
                                                var matcher = new RegExp( "^" + re, "i" );
                                                var a = $.grep( part_data, function(item,index){
                                                    return matcher.test(item);
                                                });
                                                responseFn( a );
                                            }
                                        }).keydown();
                                    }
                                    else if (data.errMsg == "" && data.searchPartList == ""){
                                        var part_data = data.partNo.toString();
                                        $(current_part_list_id).val(part_data);
                                        $("#add_cup_part, #add_and_next_cup_part").attr("disabled", false);
                                        if(part_data != $(current_part_number).val().toUpperCase())
                                        {
                                            alert("Part Number does not exists, please re-enter.");
                                            $(current_part_number).val("");
                                        }
                                    }
                                }
                            },
                            error: function(data) {
                                hide_spinner();
                                alert( "Unable to Fetch Part Number List");
                            }
                        });
                    }
                }
            }, 100);
        }
    });

    //$('.part_numbers_auto').blur(function(event) {
    //    if ($("#non_contract_part_check").is(':checked') == false){
    //        var current_part_id = this.id;
    //        var current_element_id = current_part_id.slice(-1);
    //        if($.isNumeric(current_element_id)){
    //            var current_part_list_id = '#part_list'+current_element_id;
    //            var part_name_id = '#part_name'+current_element_id;
    //            var part_image_class = '.part-image'+current_element_id;
    //            var part_image_id='part_image'+current_element_id;
    //        }
    //        else {
    //            var current_part_list_id = '#part_list';
    //            var part_name_id = '#part_name';
    //            var part_image_class = '.part-image';
    //            var part_image_id='part_image'
    //        }
    //        var current_part_number = '#'+current_part_id;
    //        if($(current_part_number).val() != "") {
    //            $.ajax({
    //                url: "/kitting/parts/search",
    //                type: 'POST',
    //                data: { "part_number": $(current_part_number).val() },
    //                onLoading: show_spinner(),
    //                success: function(data) {
    //                    hide_spinner();
    //                    if(data.error_message == undefined){
    //                        $(part_name_id).val(data.part.part.name);
    //                        $(current_part_number).val(data.part.part.part_number);
    //                        $(current_part_list_id).val(data.part.part.part_number);
    //                        if (data.type != "custPN"){
    //                            $("#cust_pn_message").css("display","block");
    //                            $("#cust_pn_message").html("The Customer PN for entered Part Number "+ data.part_number_entered +" is " + data.part.part.part_number+ " .")
    //                        }
    //                        if(data.image == null || data.image == "") {
    //                        } else {
    //                            $(part_image_class).show();
    //                            $(part_image_class + ' div').children().remove();
    //                            var image_data = data.image;
    //                            if (document.location.protocol == "https:"){
    //                                var image_data = data.image.replace("http://","https://");
    //                            }
    //                            $(part_image_class + ' div').append("<img id="+part_image_id+" class=\"multipartcup_image img-responsive\" src="+image_data+" alt=\"Image Not Available\">");
    //                        }
    //                        $("#add_cup_part, #add_and_next_cup_part").attr("disabled", false);
    //                        return true;
    //                    }
    //                    else
    //                    {
    //                        $("#add_cup_part, #add_and_next_cup_part").attr("disabled", true);
    //                        $.msgBox({
    //                            title:"Part Status",
    //                            content: data.error_message
    //                        });
    //                        return false;
    //                    }
    //                },
    //                error: function(jqXHR, textStatus) {
    //                    hide_spinner();
    //                    $("#add_cup_part, #add_and_next_cup_part").attr("disabled", true);
    //                    alert( "Unable to Fetch Part Number List" );
    //                }
    //            });
    //        }
    //        else{
    //            hide_spinner();
    //            $("#add_cup_part, #add_and_next_cup_part").attr("disabled", true);
    //            $(part_name_id).val("");
    //            $("img#part_image").remove();
    //            return false;
    //        }
    //    }
    //});

    $(".demand_quantities").keyup(function() {
        var value =$(this).val();
        var word = "";
        if (isNaN(value.charAt(0)))
        {
            var regexp = /[WLwlSsEe]/;
        }
        else
        {
            var regexp = /[0-9]/;
        }
        for (i=0; i < value.length; i++)
        {
            x = value.charAt(i);
            if(regexp.test(x))
            {
                word += x;
            }
            else
            {
                word = word.replace(x, "");
            }
        }
        $(this).val(word.toUpperCase())
    });
    $('.uoms').change(function(event) {
        if ($("#non_contract_part_check").is(':checked') == false){
            var current_part_id = this.id;
            var current_element_id = current_part_id.slice(-1);
            if($.isNumeric(current_element_id)){
                var current_part_number_uom = '#part_number_auto'+current_element_id;
            }
            else{
                var current_part_number_uom = '#part_number_auto';
            }
            $.ajax({
                beforeSend: function(){
                    show_spinner();
                    $("#add_cup_part, #add_and_next_cup_part").attr("disabled", true);
                },
                url: "/kitting/kits/uom_look_up",
                type: 'GET',
                data: {part : $(current_part_number_uom).val().toUpperCase(), uom : $(this).val()},
                success: function(data) {
                    hide_spinner();
                    if(data.errMsg == null || data.errMsg == ""){
                        $('#loading').css('visibility','hidden');
                        $("#add_cup_part, #add_and_next_cup_part").attr("disabled", false);
                        $('#add_remove_new_part').show();
                    }
                    else {
                        alert(data.errMsg);
                        $('#loading').css('visibility','hidden');
                        $("#add_cup_part, #add_and_next_cup_part").attr("disabled", true);
                        $('#add_remove_new_part').hide();
                        $(this).focus();
                        return false;
                    }
                },
                error: function(jqXHR, textStatus) {
                    hide_spinner();
                    alert( "Unsuccessful Request: ");
                }
            });
        }
    });
});

$("body").on('click','a.part_row_delete', function(e) {
    if((parseInt($('.multi_cup_parts').children().length)/2) > 1) {
        var current_element_number = this.id.slice(-1);
        $(this).parent().parent().prev().andSelf().remove();
        if($.isNumeric(current_element_number)){
            $('.part_numbers_auto').each(function(i){
                if(i >= (current_element_number-1)){
                    $(this).attr("id","part_number_auto"+(i+1));
                    $(this).attr("name","part_number_auto"+(i+1));
                    $(this).parent().next().find( "input[id='part_name"+(i+2)+"']").attr("id", "part_name"+(i+1));
                    $(this).parent().next().find( "input[name='part_name"+(i+2)+"']").attr("name", "part_name"+(i+1));
                    $(this).parent().parent().find(".part-image"+(i+2)).attr("class","row-fluid part-image"+(i+1));
                    $(this).parent().parent().find('.part-image'+(i+1)).children().children().attr("id","part_image"+(i+1));
                    $(".part_div"+(i+2)).attr("class","row-fluid part_div"+(i+1));
                    $("#part_remove_div"+(i+2)).attr("id","part_remove_div"+(i+1));
                    $("#remove_part"+(i+2)).attr("id","remove_part"+(i+1));
                }
            });
            $('.demand_quantities').each(function(i){
                if(i >= (current_element_number-1)){
                    $(this).attr("id","demand_quantity"+(i+1));
                    $(this).attr("name","demand_quantity"+(i+1));
                }
            });

            $('.uoms').each(function(i){
                if(i >= (current_element_number-1)){
                    $(this).attr("id","uom"+(i+1));
                    $(this).attr("name","uom"+(i+1));
                }
            });
        }
        else {
            $('.part_numbers_auto').each(function(i){
                if(i==0 ){
                    $(this).attr("id","part_number_auto");
                    $(this).attr("name","part_number_auto");
                    $(this).parent().next().find( "input[id='part_name"+(i+2)+"']").attr("id", "part_name");
                    $(this).parent().next().find( "input[name='part_name"+(i+2)+"']").attr("name", "part_name");
                    $(this).parent().parent().find(".part-image"+(i+2)).attr("class","row-fluid part-image");
                    $(this).parent().parent().find('.part-image'+(i+1)).children().children().attr("id","part_image");
                    $(".part_div"+(i+2)).attr("class","row-fluid part_div");
                    $("#part_remove_div"+(i+2)).attr("id","part_remove_div");
                    $("#remove_part"+(i+2)).attr("id","remove_part");
                }
                else {
                    $(this).attr("id","part_number_auto"+(i+1))
                    $(this).attr("name","part_number_auto"+(i+1));
                    $(this).parent().next().find( "input[id='part_name"+(i+2)+"']").attr("id", "part_name"+(i+1));
                    $(this).parent().next().find( "input[name='part_name"+(i+2)+"']").attr("name", "part_name"+(i+1));
                    $(this).parent().parent().find(".part-image"+(i+2)).attr("class","row-fluid part-image"+(i+1));
                    $(this).parent().parent().find('.part-image'+(i+1)).children().children().attr("id","part_image"+(i+1));
                    $(".part_div"+(i+2)).attr("class","row-fluid part_div"+(i+1));
                    $("#part_remove_div"+(i+2)).attr("id","part_remove_div"+(i+1));
                    $("#remove_part"+(i+2)).attr("id","remove_part"+(i+1));
                }
            });

            $('.demand_quantities').each(function(i){
                if(i==0 ){
                    $(this).attr("id","demand_quantity");
                    $(this).attr("name","demand_quantity");
                }
                else {
                    $(this).attr("id","demand_quantity"+(i+1));
                    $(this).attr("name","demand_quantity"+(i+1));
                }
            });

            $('.uoms').each(function(i){
                if(i==0 ){
                    $(this).attr("id","uom");
                    $(this).attr("name","uom");
                }
                else {
                    $(this).attr("id","uom"+(i+1));
                    $(this).attr("name","uom"+(i+1));
                }
            });
        }

    }
    else {
        $(this).parent().parent().prev().andSelf().remove();
        $("#add_remove_new_part").remove();
    }
});
setInterval(function() {
    var status = $('.upload_status').map(function(){return $(this).text()});
    var status = $.grep( jQuery.makeArray(status), function( n, i ) {
        return n == "UPLOADING" || n == "PROCESSING";
    });
    if($("#kit_bom_bulk_operation_operation_type").val()== "AD HOC KIT"){
        var path = "/kitting/kits/upload_status/?id="+$("#page_no").attr("val")+"&type=ADHOC"
    }
    else{
        var path = "/kitting/kits/upload_status/?id="+$("#page_no").attr("val")
    }
    if ( status.length != 0 ) {
        $(".upload_details").load(path,function(data){
            load_table_sorter();
        })
    }
}, 3000);