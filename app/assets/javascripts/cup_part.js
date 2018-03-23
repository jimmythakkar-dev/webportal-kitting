$(document).ready(function() {
    $("#cup_parts").click(function() {
        $('#myModal').modal('show')
    });

    var $addAndAddNextCupPart = $("#add_cup_part, #add_and_next_cup_part , #update_cup_part");
    var $partNumberBox = $('#part_number_auto');


    $("#populate_cup_detail").load_compartment();

    $addAndAddNextCupPart.on("click",function(event){
        var data_id = $("#cup_id").val();
        var cup_id =  $("ul[data-id='" + data_id + "']").attr('id');
        var $demandQuantity = $('#demand_quantity');
        if ($(this).attr("id") == "add_cup_part"){
            $("#dup_cup_num").val($("#cup_number").val());
            $("#cup_number").val("");
        }
        var Qty = $demandQuantity.val();
        if (Qty != ""){
            if(isNaN(parseInt(Qty)) && Qty != 'WL' && Qty != 'wl' && Qty != 'Wl'&& Qty != 'wL'){
                alert( "Please enter valid Quantity.");
                $demandQuantity.focus();
                return false;
            }
            else if(parseInt(Qty) > 1000 || parseInt(Qty) <= 0)
            {
                alert("Please enter valid Quantity.");
                $demandQuantity.focus();
                return false;
            }
        }

        if ($("#uom").val() == ""){
            alert("Please select UOM");
            return false;
            event.preventDefault();
        }


        if($(this).val() == "Update"){
            if ( $(".part_qty_n_uom").find(".demand_quantities").length > 1){

                if($(".part_qty_n_uom .demand_quantities").val() != "WL"){
                    if($demandQuantity.val() == "WL"){
                        alert("Please enter quantity as Number.");
                        $demandQuantity.val('');
                        $demandQuantity.focus();
                        return false;
                    }
                }else{
                    if($demandQuantity.val() != "WL"){
                        alert("Please enter quantity as WL.");
                        $demandQuantity.val('');
                        $demandQuantity.focus();
                        return false;
                    }
                }
            }
        }
        else if($(this).val() == "Add"){
            if ( $(".part_qty_n_uom").find(".demand_quantities").length > 0){
                if($(".part_qty_n_uom .demand_quantities").val() != "WL"){
                    if($demandQuantity.val() == "WL"){
                        alert("Please enter quantity as Number.");
                        $demandQuantity.val('');
                        $demandQuantity.focus();
                        return false;
                    }
                }else{
                    if($demandQuantity.val() != "WL"){
                        alert("Please enter quantity as WL.");
                        $demandQuantity.val('');
                        $demandQuantity.focus();
                        return false;
                    }
                }
            }
        }


        if ($("#non_contract_part_check").is(':checked') == true) {
            if($partNumberBox.val() == "") {
                alert("Please Enter Part Number");
                $partNumberBox.focus();
                return false;
            }

            else if($demandQuantity.val() == "" && $partNumberBox.val() != "") {
                alert("Please Enter Valid Quantity.");
                $demandQuantity.focus();
                return false;
            }
            else {
                $.ajax({
                    url: "/kitting/parts/search",
                    type: 'POST',
                    data: { "part_number": $partNumberBox.val(), "part_type": "NonContract", "part_name": $('#part_name').val() },
                    onLoading: show_spinner(),
                    async: false,
                    success: function(data) {
                        hide_spinner();
                        if(data.error_message == undefined) {
                            return true;
                        }
                        else {
                            $.msgBox({
                                title:"Part Status",
                                content: data.error_message
                            });
                            return false;
                        }
                    },
                    error: function(jqXHR, textStatus) {
                        hide_spinner();
                        alert( "Please Try Again" );
                    }
                });
            }
        }
    });

//    --------------------------------------------------------
//        OnClick Pages on add part popup
//    --------------------------------------------------------
    $("#part_select_modal, #part_select_modal_binder").on("click",".popup_pages", function(){
        var cup_id = $(this).attr('id');
        //$(".popup_pages").removeClass("active");
        //$(this).addClass("active");
        $.get('/kitting/cups/'+cup_id+'/build', function(data) {
            $('#part_select_modal').modal({"backdrop": "static"});
            $('#cup_id').val(cup_id);
            $("#cup_number").val($("a#"+cup_id+"").html());
            $("#cup_number_info").text($("a#"+cup_id+"").html());

        });
    });

    $("#demand_quantities").keyup(function() {
        var value =$(this).val();
        var word = "";
        if (isNaN(value.charAt(0)))
        {
            var regexp = /[WLwl]/;
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


    $partNumberBox.on("keypress paste",function (){
        $addAndAddNextCupPart.attr("disabled", false);
        if ($("#non_contract_part_check").is(':checked') == false) {
            setTimeout(function () {
                if ($partNumberBox.val().length >= 4) {
                    if ($.active == 0) {
                        $.ajax({
                            url: "/kitting/kits/part_look_up",
                            type: 'POST',
                            data: { "part_number": $partNumberBox.val() },
                            onLoading: show_spinner(),
                            success: function (data) {
                                hide_spinner();
                                if (data == null) {
                                    alert("Service temporary unavailable, sorry for inconvenience");
                                    $('#loading').css('visibility', 'hidden');
                                    $partNumberBox.val("");
                                }
                                else {
                                    if (data.errMsg == "" && data.searchPartList != "") {
                                        var part_data = data.searchPartList;
                                        $("#part_list").val(part_data);
                                        $addAndAddNextCupPart.attr("disabled", false);
                                        if (part_data[0] == "") {
                                            alert("Part Number does not exists, please re-enter.");
                                            $partNumberBox.val("");
                                        }
                                        $partNumberBox.autocomplete({
                                            source: function (req, responseFn) {
                                                var re = $.ui.autocomplete.escapeRegex(req.term);
                                                var matcher = new RegExp("^" + re, "i");
                                                var a = $.grep(part_data, function (item, index) {
                                                    return matcher.test(item);
                                                });
                                                responseFn(a);
                                            }
                                        }).keydown();
                                    }
                                    else if (data.errMsg == "" && data.searchPartList == "") {
                                        var part_data = data.partNo.toString();
                                        $("#part_list").val(part_data);
                                        $addAndAddNextCupPart.attr("disabled", false);
                                        if (part_data != $partNumberBox.val().toUpperCase()) {
                                            alert("Part Number does not exists, please re-enter.");
                                            $partNumberBox.val("");
                                        }
                                    }
                                }
                            },
                            error: function (data) {
                                hide_spinner();
                                alert("Unable to Fetch Part Number List");
                            }
                        });
                    }
                }
            }, 100);
        }

    });

    $partNumberBox.on('blur',function(event) {
        if ($("#non_contract_part_check").is(':checked') == false){
            var current_part_id = this.id;
            var current_element_id = current_part_id.slice(-1);
            if($.isNumeric(current_element_id)){
                var current_part_list_id = '#part_list'+current_element_id;
                var part_name_id = '#part_name'+current_element_id;
                var part_image_class = '.part-image'+current_element_id;
                var part_image_id='part_image'+current_element_id;
            }
            else {
                var current_part_list_id = '#part_list';
                var part_name_id = '#part_name';
                var part_image_class = '.part-image';
                var part_image_id='part_image'
            }
            var current_part_number = '#'+current_part_id;
            if($(current_part_number).val() != "") {
                $.ajax({
                    url: "/kitting/parts/search",
                    type: 'POST',
                    data: { "part_number" : $(current_part_number).val() },
                    onLoading: show_spinner(),
                    success: function(data) {
                        hide_spinner();
                        if(data.error_message == undefined){
                            $(part_name_id).val(data.part.part.name);
                            $(current_part_number).val(data.part.part.part_number);
                            $(current_part_list_id).val(data.part.part.part_number);
                            if (data.type != "custPN"){
                                $("#cust_pn_message").css("display","block");
                                $("#cust_pn_message").html("The Customer PN for entered Part Number "+ data.part_number_entered +" is " + data.part.part.part_number+ " .")
                            }
                            if(data.image == null || data.image == "") {
                            } else {
                                $(part_image_class).show();
                                $(part_image_class + ' div').children().remove();
                                var image_data = data.image;
                                if (document.location.protocol == "https:"){
                                    var image_data = data.image.replace("http://","https://");
                                }
                                $(part_image_class + ' div').append("<img id="+part_image_id+" class=\"multipartcup_image img-responsive\" src="+image_data+" alt=\"Image Not Available\">");
                            }
                            $("#add_cup_part, #add_and_next_cup_part").attr("disabled", false);
                            return true;
                        }
                        else
                        {
                            $addAndAddNextCupPart.attr("disabled", true);
                            $.msgBox({
                                title:"Part Status",
                                content: data.error_message
                            });
                            return false;
                        }
                    },
                    error: function(jqXHR, textStatus) {
                        hide_spinner();
                        $addAndAddNextCupPart.attr("disabled", true);
                        alert( "Unable to Fetch Part Number List" );
                    }
                });
            }
            else {
                hide_spinner();
                alert("Please enter a valid Part Number.");
                $addAndAddNextCupPart.attr("disabled", true);
                $(part_name_id).val("");
                $("img#part_image").remove();
                return false;
            }
        }
    });

    $("#part_select_modal").find("select#uom").change(function(event) {
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
                    $addAndAddNextCupPart.attr("disabled", true);
                },
                url: "/kitting/kits/uom_look_up",
                type: 'GET',
                data: {part : $(current_part_number_uom).val().toUpperCase(), uom : $(this).val()},
                success: function(data) {
                    hide_spinner();
                    if(data.errMsg == null || data.errMsg == ""){
                        $('#loading').css('visibility','hidden');
                        $addAndAddNextCupPart.attr("disabled", false);
                    }
                    else {
                        alert(data.errMsg);
                        $('#loading').css('visibility','hidden');
                        $addAndAddNextCupPart.attr("disabled", true);
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

    $(".popup-edit").on("click",function() {
        $('#table tbody').remove();
        var cup_number =$(this).parent().parent().find('td:first').find('input').val()
        $('#edit_cup_number_info').text(cup_number);
        var cup_id = $(this).parent().parent().find("input[name='cup_id[]']").val();
        var quantity = $(this).parent().parent().find("input[name='quantity']").val();
        var part_number = $(this).parent().parent().find("input[name='part_number']").val();
        var selectValues = []
        for (var i = 1; i <= 1000; i++)
        {
            selectValues.push(i) ;
        }

        strToAdd = '<tr><td>'+part_number+'</td>'+
            '<td><input class="input-sm mySelect" id="actual_quantity" name="Quantities[]" value="'+quantity+'" required="required" maxlength="4" autocomplete="off">'+
            '<td><img class="ImgDelete" src="/assets/delete.gif"/></td>'+
            '<input name="cup_id_for_delete[]" id="cup_id_for_delete" value="'+cup_id+'" type="hidden" />'+
            '<input name="part_number_for_delete[]" id="part_number_for_delete_'+part_number+'" value="'+part_number+'" type="hidden" />'+
            '<input name="old_quantities[]" id="old_quantities'+quantity+'" value="'+quantity+'" type="hidden" /></tr>';
        $('#table').append(strToAdd);
        $('#part_edit_modal_binder').modal('show');
    });
    $('#binder_table').delegate(".binder_part_number_auto", 'keypress paste', function() {
        var index = $(this).attr('id').replace( /[^\d.]/g, '' );
        $("#binder_add_part_"+index).attr("disabled", false);
        if ($("#non_contract_part_check_"+index).is(':checked') == false) {
            setTimeout(function () {
                if ($("#part_number_auto_"+index).val().length >= 4) {
                    if ($.active == 0) {
                        $.ajax({
                            url: "/kitting/kits/part_look_up",
                            type: 'POST',
                            data: { "part_number": $("#part_number_auto_"+index).val() },
                            onLoading: show_spinner(),
                            success: function (data) {
                                hide_spinner();
                                if (data == null) {
                                    alert("Service temporary unavailable, sorry for inconvenience");
                                    $('#loading').css('visibility', 'hidden');
                                    $("#part_number_auto_"+index).val("");
                                }
                                else {
                                    if (data.errMsg == "" && data.searchPartList != "") {
                                        var part_data = data.searchPartList;
                                        $("#part_list").val(part_data);
                                        $("#binder_add_part_"+index).attr("disabled", false);
                                        if (part_data[0] == "") {
                                            alert("Part Number does not exists, please re-enter.");
                                            $("#part_number_auto_"+index).val("");
                                        }
                                        $("#part_number_auto_"+index).autocomplete({
                                            source: function (req, responseFn) {
                                                var re = $.ui.autocomplete.escapeRegex(req.term);
                                                var matcher = new RegExp("^" + re, "i");
                                                var a = $.grep(part_data, function (item, i) {
                                                    return matcher.test(item);
                                                });
                                                responseFn(a);
                                            }
                                        }).keydown();
                                    }
                                    else if (data.errMsg == "" && data.searchPartList == "") {
                                        var part_data = data.partNo.toString();
                                        $("#part_list").val(part_data);
                                        $("#binder_add_part_"+index).attr("disabled", false);
                                        if (part_data != $("#part_number_auto_"+index).val().toUpperCase()) {
                                            alert("Part Number does not exists, please re-enter.");
                                            $("#part_number_auto_"+index).val("");
                                        }
                                    }
                                }
                            },
                            error: function (data) {
                                hide_spinner();
                                alert("Unable to Fetch Part Number List");
                            }
                        });
                    }
                }
            }, 100);
        }

    });
    $('#binder_table').delegate(".binder_part_number_auto", 'blur', function() {
        var index = $(this).attr('id').replace( /[^\d.]/g, '' );
        if ($("#non_contract_part_check_"+index).is(':checked') == false){
            if($("#part_number_auto_"+index).val() != "") {
                $.ajax({
                    url: "/kitting/parts/search",
                    type: 'POST',
                    data: { "part_number" : $("#part_number_auto_"+index).val() },
                    onLoading: show_spinner(),
                    success: function(data) {
                        hide_spinner();
                        if(data.error_message == undefined){
                            $('#part_name_'+index).val(data.part.part.name);
                            $("#part_number_auto_"+index).val(data.part.part.part_number);
                            if (data.type != "custPN"){
                                $("#cust_pn_message").css("display","block");
                                $("#cust_pn_message").html("The Customer PN for entered Part Number "+ data.part_number_entered +" is " + data.part.part.part_number+ " .")
                            }
                            if(data.image == null || data.image == "") {
                            } else {
                                $('.part-image').show();
                                $('.part-image div').children().remove();
                                var image_data = data.image;
                                if (document.location.protocol == "https:"){
                                    var image_data = data.image.replace("http://","https://");
                                }
                                $('.part-image div').append("<img id=\"part_image\" src="+image_data+" alt=\"Image Not Available\">");
                            }
                            $("#binder_add_part_"+index).attr("disabled", false);
                            return true;
                        }
                        else
                        {
                            $("#binder_add_part_"+index).attr("disabled", true);
                            $.msgBox({
                                title:"Part Status",
                                content: data.error_message
                            });
                            return false;
                        }
                    },
                    error: function(jqXHR, textStatus) {
                        hide_spinner();
                        $("#binder_add_part_"+index).attr("disabled", true);
                        alert( "Unable to Fetch Part Number List" );
                    }
                });
            }
            else {
                hide_spinner();
                alert("Please enter a valid Part Number.");
                $("#binder_add_part_"+index).attr("disabled", true);
                return false;
            }
        }
        else {
            if($("#part_number_auto_"+index).val() != "") {
                $.ajax({
                    url: "/kitting/parts/search",
                    type: 'POST',
                    data: { "part_number": $("#part_number_auto_"+index).val(), "part_type": "NonContract", "part_name": $('#part_name_'+index).val() },
                    onLoading: show_spinner(),
                    async: false,
                    success: function(data) {
                        hide_spinner();
                        if(data.error_message == undefined) {
                            return true;
                        }
                        else {
                            $.msgBox({
                                title:"Part Status",
                                content: data.error_message
                            });
                            return false;
                        }
                    },
                    error: function(jqXHR, textStatus) {
                        hide_spinner();
                        alert( "Please Try Again" );
                    }
                });
            }
            else {
                hide_spinner();
                alert("Please enter a valid Part Number.");
                $("#binder_add_part_"+index).attr("disabled", true);
                return false;
            }
        }
    });

    $('#binder_table').delegate(".binder_uom", 'change', function() {
        var index = $(this).attr('id').replace( /[^\d.]/g, '' );
        if ($("#non_contract_part_check_"+index).is(':checked') == false){
            $.ajax({
                beforeSend: function(){
                    show_spinner();
                    $("#binder_add_part_"+index).attr("disabled", true);
                },
                url: "/kitting/kits/uom_look_up",
                type: 'GET',
                data: {part : $("#part_number_auto_"+index).val().toUpperCase(), uom : $(this).val()},
                success: function(data) {
                    hide_spinner();
                    if(data.errMsg == null || data.errMsg == ""){
                        $('#loading').css('visibility','hidden');
                        $("#binder_add_part_"+index).attr("disabled", false);
                    }
                    else {
                        alert(data.errMsg);
                        $('#loading').css('visibility','hidden');
                        $("#binder_add_part_"+index).attr("disabled", true);
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

    $(".non_contract_binder").on("change", function(event) {
        var current_id = this.id.match(/\d+/)[0];
        if($(this).is(':checked')) {
            $("#part_number_auto_"+current_id).val('');
            $("#part_name_"+current_id).val('');
            //            $("#part_name_"+current_id).prop("disabled", false);
            $("#demand_quantity_"+current_id).val('');
        }
        else {
            $("#part_number_auto_"+current_id).val('');
            $("#part_name_"+current_id).val('');
            $("#part_name_"+current_id).prop("disabled", true);
            $("#demand_quantity_"+current_id).val('');
        }
    });

    $(".binder_finish_kit, #multi_binder_save").on("click",function(e) {
        var parts=[], qty = [], non_cont_statuses = [],uoms=[],tray_nos=[];
        $(".binder_part_number_auto").each(function(index){
            var current_element = this.id.match(/\d+/)[0];
            var part_number_val = $("#part_number_auto_"+(current_element)).val();
            var demand_qty_val = $("#demand_quantity_"+(current_element)).val();
            var non_contract_val = $("#non_contract_part_check_"+(current_element)).is(':checked');
            var uom_val = $("#uom_"+(current_element)).val();
            var tray_no_val = $("#kit_tray_"+(current_element)).val();

            if (part_number_val == "" || demand_qty_val == "") {
                $(this).parent().parent().parent().parent().remove()
            }
            else {
                parts.push(part_number_val);
                qty.push(demand_qty_val);
                non_cont_statuses.push(non_contract_val);
                uoms.push(uom_val);
                tray_nos.push(tray_no_val);
            }
        });
        var mmt_kit = $("#mmt_kit_id").val();
        if(parts.length > 0) {
            $.ajax({
                url: "/kitting/cup_parts/add_parts_for_binder",
                type: 'GET',
                data: {
                    "kit_id": $("#kit_id").val(),
                    "part_numbers": parts,
                    "quantities": qty,
                    "nc_status": non_cont_statuses,
                    "uoms": uoms,
                    "tray_nos": tray_nos,
                    "mmt_kit_id": mmt_kit
                },
                onLoading: show_spinner(),
                async: false,
                success: function(data) {
                    hide_spinner();
//                        if(data.error_message == undefined) {
//                            return true;
//                        }
//                        else {
//                            $.msgBox({
//                                title:"Part Status",
//                                content: data.error_message
//                            });
//                            return false;
//                        }
                },
                error: function(jqXHR, textStatus) {
                    hide_spinner();
                    alert( "Please Try Again" );
                }
            });
        }
    });
    $('#binder_table').delegate('img.delete_row', 'click', function(e) {
        $(this).parent().parent().remove();
    });


});

function check_non_contract_part_checkbox(check_box) {

    var check_state = 0;
    var $partName = $("#part_name");
    var $addPartLine = $('.add_part_line');
    if(check_box.checked){
        check_state = 1;
    }

    $("#update_cup_part").css("display","none");
    $("#add_cup_part").css("display","block");

    $("#cup_part_data").trigger("reset");

    check_box.setAttribute('checked', check_state);
    check_box.checked = check_state;

    if(check_box.checked) {
        $("#add_cup_part, #add_and_next_cup_part, #part_name").prop("readonly", false);
        $("img#part_image").remove();
        $partName.prop("disabled", false);
        $addPartLine.hide();   // Confusion
    }
    else {
        $("#part_number_auto").prop("readonly", false);
        $partName.prop("disabled", true);
        $addPartLine.show();   // Confusion
    }
}

function clear_add_new_part_row()
{
    var $addNewCupPart = $(".add_new_cup_parts");
    var $nonContractPartCheck = $("#non_contract_part_check");
    $addNewCupPart.find('input#part_number_auto').val('');
    $addNewCupPart.find('input#part_number_auto').attr("readonly", false);
    $addNewCupPart.find('input#part_name').val('');
    $addNewCupPart.find('input#part_name').attr("readonly", true);
    $addNewCupPart.find('input#demand_quantity').val('');
    $addNewCupPart.find('input#uom').val('');
    $nonContractPartCheck.prop("checked", false);
    $nonContractPartCheck.attr("disabled", false);
    $("img#part_image").remove();

    show_hide_add_update_btn("block","none","none");

}

function to_do_on_edit_btn_click(edit_btn)
{
    var $addNewCupPart = $(".add_new_cup_parts");
    var $quantityInfoText= $(".quantity_info_text");
    var $popupThumbnail = $(".popup_thumbnail");
    var part_number = '';
    var part_name = '';
    var quantity = '';
    var uom = '';

    $addNewCupPart.css("visibility", "visible");
    $quantityInfoText.css("visibility", "visible");


    part_number = edit_btn.parent().find('.part_number').children().text();
    part_name = edit_btn.parent().find('.part_name').text();
    quantity = edit_btn.parent().find('.part_qty_n_uom').find('.demand_quantities').attr('value');
    uom = edit_btn.parent().find('.part_qty_n_uom').find('.uom').text();

    $addNewCupPart.find('input#part_number_auto').val(part_number).attr("readonly",true);
    $addNewCupPart.find('input#part_name').val(part_name);
    $addNewCupPart.find('input#demand_quantity').val(quantity);
    $addNewCupPart.find('input#uom').val(uom);

    $popupThumbnail.css('display','block');
    edit_btn.parent().parent().css('display','none');
    edit_btn.parent().parent().addClass('hide_cup_part_thum');
//    $popupThumbnail.addClass('hide_cup_part_thum');
    show_hide_add_update_btn("none","block","block");

}

function show_hide_add_update_btn( value1, value2, value3){
    var addBtn = $("#add_cup_part");
    var updateBtn = $("#update_cup_part");
    var cancelBtn = $("#cancel_update");
    addBtn.css("display", value1);
    updateBtn.css("display", value2);
    cancelBtn.css("display", value3);
}

function hide_add_new_popup(){
    var $addNewCupPart = $(".add_new_cup_parts");
    var $quantityInfoText = $(".quantity_info_text");

        if($(".popup_thumbnail .non_edit_popup_part_qty, .wl_edit_popup_part_qty").length > 0){
            $addNewCupPart.css("visibility", "hidden");
            $quantityInfoText.css("visibility", "hidden");
        }else{
            if ($("#multiple_part").val() == "true"){
                $addNewCupPart.css("visibility", "visible");
                $quantityInfoText.css("visibility", "visible");
            }
            else if($(".popup_thumbnail").length == 0){
                $addNewCupPart.css("visibility", "visible");
                $quantityInfoText.css("visibility", "visible");
            }
            else{
                $addNewCupPart.css("visibility", "hidden");
                $quantityInfoText.css("visibility", "hidden");
            }
        }
}