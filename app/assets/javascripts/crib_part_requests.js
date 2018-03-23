$(document).ready(function(){
    $("#ship_crib_part").on("click",function(){
        var ch_cnt = 0;
        ch_cnt = $("table .ship_part_list").find("input[type=checkbox]:checked").length;
        if(ch_cnt > 0){
            return true
        }else{
            alert("Please check checkbox for bag label");
            return false
        }
    });
    $(".print_crib_parts").on("click",function(){
        var ch_cnt = 0;
        ch_cnt = $("table .print_crib_part").find("input[type=checkbox]:checked").length;
        if(ch_cnt > 0){
            return true
        }else{
            alert("Please check checkbox for bag label");
            return false
        }
    });

    $(".pick_crib_parts").on("click",function(){
        var ch_cnt = 0;
        ch_cnt = $("table .td_pick_crib_part").find("input[type=checkbox]:checked").length;
        if(ch_cnt > 0){
            return true
        }else{
            alert("Please select at least one part for pick sheet");
            return false
        }
    });
    $("body").on("keyup", ".phillyQuantity", function (e) {
        if(this.value.match(/[^0-9.]/g)){
            alert(I18n.t("floating_qty"));
            $(this).val(0);
        }
    });
    $("body").on("blur",".phillyQuantity",function(e){
        var tr = $(this).closest("tr");
        var value = $(this).attr("id").split("_").pop();
        var part_number = $("#philly_pn_"+value).val();
        var qty= $("p#philly_qty_"+value).attr("val");
        if (isNaN(parseFloat($(this).val()))){
            $(this).val("0");
            return false;
        }
        if($(this).val() != "0" && !isNaN(parseFloat($(this).val())) && parseFloat($(this).val()) != 0 ){
            $(this).val(parseFloat($(this).val()));
            var entered_qty = parseFloat($(this).val());
            show_spinner();
            $.get( "/kitting/crib_part_requests/get_binloc?part_no="+part_number, function( data ) {
                hide_spinner();
                if(data.status == true){
                    if (data.list.length > 0 ){

                    }
                    else{
                        var stat = confirm("No Bin Location available for this part. would you like to Continue or contact your KLX representative ?");
                        if (stat){

                        }else{
                            tr.remove();
                        }
                    }
                }else{
                    $(this).val(0);
                    alert("Request Unsuccessful , Try Again")
                }
            });
        }
        else{
            $(this).val(parseFloat($(this).val()));
        }
    });
    $("body").on("change", "#philly_stId,#philly_dpId,#philly_kpnId,#philly_acId", function (e) {
        $(this).parent().children().remove(".agusta_req_error");
    });
    $("body").on("click", "#cribSubmit", function (e) {
        show_spinner();
        var empty_motive = [];
        $(".phillyQuantity").each(function(index,value){
            if( parseFloat($(this).val()) > 0 ){
                if ( $(value).parent().next("td").children("select").prop("selectedIndex") == 0 ){
                    empty_motive.push($(value).parent().next("td").children("select"));
                }
            }
        });

        if ($('#philly_acId').val() == "") {
            if($(".agusta_aircraft_id").children().length <= 2) {
                $(".agusta_aircraft_id").append("<label class=\"agusta_req_error\" >"+I18n.t('select_aircraft')+"</label>");
            }
            $("#philly_acId:first").focus();
            hide_spinner();
            return false;
        }
        else if ($('#philly_kpnId').val() == "") {
            if($(".agusta_kit_part_no").children().length <= 2) {
                $(".agusta_kit_part_no").append("<label class=\"agusta_req_error\" >"+I18n.t('select_kpn')+"</label>");
            }
            $("#philly_kpnId:first").focus();
            hide_spinner();
            return false;
        }
        else if ($('#philly_stId').val() == "") {
            if($(".agusta_station").children().length <= 2) {
                $(".agusta_station").append("<label class=\"agusta_req_error\" >"+I18n.t('select_station')+"</label>");
            }
            $("#philly_stId:first").focus();
            hide_spinner();
            return false;
        }
        else if ($('#philly_dpId').val() == "") {
            if($(".agusta_discharge_point").children().length <= 2) {
                $(".agusta_discharge_point").append("<label class=\"agusta_req_error\" >"+I18n.t('select_discharge_point')+"</label>");
            }
            $("#philly_dpId:first").focus();
            hide_spinner();
            return false;
        }

        else if ($(".note_check").length > 0){
            $(".note_check:first").focus();
            hide_spinner();
            return false;
        }

        else if(empty_motive.length > 0) {
            if( empty_motive[0].parent().children().length <= 1) {
                empty_motive[0].parent().append("<label class=\"select_agusta_motive\" >"+I18n.t('select_agusta_motive')+"</label>");
            }
            empty_motive[0].focus();
            hide_spinner();
            return false;
        }
        else {
            return true;
        }
    });

// ADD PART LOGIC
    $("body").on("click", "#additionalPhillyPartID", function () {
        if ($("#autocomplete_kpn").val() == "") {
            alert(I18n.t("valid_part_number"));
            return false;
        }
        else if($.trim($("#add_uom").val()) == ""){
            alert("Enter Valid UOM");
            return false;
        }
        else {
            if ( $("#autocomplete_kpn").val().replace(/\s/g,"") != "" ) {
                show_spinner();
                $.ajax({
                    url: "/kitting/crib_part_requests/validate_part_no",
                    type: 'GET',
                    data: {
                        "partNo": $("#autocomplete_kpn").val(),
                        "phillyKit": $("#tr_count").attr("value"),
                        "uom": $("#add_uom").val()
                    },
                    success: function (data) {
                        $("#autocomplete_kpn").val("");
                        $("#add_uom").val("");
                        $("#tr_count").attr("value",parseInt($("#tr_count").attr("value"))+ 1);
                        if (data == null) {
                            hide_spinner();
                            alert(I18n.t("rbo_down"));
                        }
                        else {
                            hide_spinner();
                        }
                    },
                    error: function (data) {
                        hide_spinner();
                        alert(I18n.t("unsuccessful_request"));
                    }

                });

            }

        }
    });
});

function getKitPartNumbers(value,type){
    if (type == "aircraft_id") {
        $("#philly_kpnId").val("");
        $('#philly_kpnId').attr("disabled", true);
        $("#philly_stId").prop('selectedIndex', 0);
        $("#philly_dpId").prop('selectedIndex', 0);
        $("#philly_stId").attr("disabled", true);
        $("#philly_dpId").attr("disabled", true);
        $(".main_order_div").remove();
        if (value > 0) {
            show_spinner();
            $.ajax({
                url: "/kitting/crib_part_requests/get_kit_part_numbers",
                type: 'GET',
                data: {
                    "aircraft_id": $('#philly_acId').val()
                },
                success: function (data) {
                    if (data == null) {
                        hide_spinner();
                        alert(I18n.t("rbo_down"));
                    }
                    else{
                        var kit_pn = data.kit_part_nos;
                        hide_spinner();
                        $('#philly_kpnId').html("<option value=\"\">" + I18n.t("select") + "</option>");
                        $.each(kit_pn, function(index, value) {
                            var opt = $('<option/>');
                            opt.attr('value', value[0]);
                            opt.text(value[1]);
                            opt.appendTo('#philly_kpnId');
                            $("#philly_kpnId").prop('selectedIndex', 0);
                            $('#philly_kpnId').attr("disabled", false);
                        });
                    }
                },
                error: function (data) {
                    hide_spinner();
                    alert("Unsuccessful Request");
                }
            });
        }
        else{
            $("#philly_kpnId").val("");
            $('#philly_kpnId').attr("disabled", true);
            $("#philly_stId").prop('selectedIndex', 0);
            $("#philly_dpId").prop('selectedIndex', 0);
            $("#philly_stId").attr("disabled", true);
            $("#philly_dpId").attr("disabled", true);
        }
    }
    else{
        if ($('#philly_acId').val() != "" && $('#philly_kpnId').val() != "" && value > 0  ) {
            show_spinner();
            $.ajax({
                url: "/kitting/crib_part_requests/populate_kit_details",
                type: 'GET',
                data: {
                    "aircraft_id": $('#philly_acId').val(),
                    "kit_part_no": $('#philly_kpnId').val()
                },
                success: function (data) {
                    if (data == null) {
                        hide_spinner();
                        alert(I18n.t("rbo_down"));
                    }
                    else {
                        $("#philly_stId").attr("disabled", false);
                        $("#philly_dpId").attr("disabled", false);
                        hide_spinner();
                    }
                },
                error: function (data) {
                    hide_spinner();
                    alert("Unsuccessful Request");
                }
            });
        }
        else {
            $("#philly_kpnId").prop('selectedIndex', 0);
            $("#philly_stId").prop('selectedIndex', 0);
            $("#philly_dpId").prop('selectedIndex', 0);
            $("#philly_acId").prop('selectedIndex', 0);
            $("#philly_stId").attr("disabled", true);
            $("#philly_dpId").attr("disabled", true);
            $(".main_order_div").remove();
            return false;
        }
    }
}
function agustaPhillyResetFM() {
    $('#philly_acId').val('');
    $("#philly_kpnId").val("");
    $('#philly_kpnId').attr("disabled",true);
    $("#philly_stId").prop('selectedIndex', 0);
    $("#philly_stId").attr("disabled", true);
    $("#philly_dpId").prop('selectedIndex', 0);
    $("#philly_dpId").attr("disabled", true);
    $(".main_order_div").remove();
}

function agustaPhillyAddParts() {
    if ($('#philly_acId').val() == "" && $('#philly_stId').val() == "" && $('#philly_dpId').val() == "") {
        if($(".agusta_aircraft_id").children().length <= 2) {
            $(".agusta_aircraft_id").append("<label class=\"agusta_req_error\" >"+I18n.t('select_aircraft')+"</label>");
        }
        $("#philly_acId:first").focus();
        //        alert(I18n.t("select_aircraft"));
        return false;
    }
    else if ($('#philly_stId').val() == "") {
        if($(".agusta_station").children().length <= 2) {
            $(".agusta_station").append("<label class=\"agusta_req_error\" >"+I18n.t('select_station')+"</label>");
        }
        $("#philly_stId:first").focus();
        return false;
    }
    else if ($('#philly_dpId').val() == "") {
        if($(".agusta_discharge_point").children().length <= 2) {
            $(".agusta_discharge_point").append("<label class=\"agusta_req_error\" >"+I18n.t('select_discharge_point')+"</label>");
        }
        $("#philly_dpId:first").focus();
        return false;
    }
    else {
        $("#aircraft_id").html($("#philly_acId").val());
        $("#station_code").html($("#philly_stId").val());
        $("#discharge_point").html($("#philly_dpId").val());
        $('#addmore_parts_modal').modal();
    }
}