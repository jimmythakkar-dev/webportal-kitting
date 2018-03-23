//START METHOD FOR ADDING NEW KIT PN IN OUTDATED BROWSERS
function add_new_kit_pn(){
    if ($("#new_pn_outdated_browser").val().trim() == ""){
        alert("ENTER A KIT P/N TO PROCEED");
    }
    else if($("#new_pn_outdated_browser").is(":disabled")){
        alert("NEW KIT P/N IS ALREADY SELECTED");
        return false;
    }
    else{
        var options = document.getElementById("kpnId").options;
        var kit_pn = [];
        var value= $("#new_pn_outdated_browser").val();
        $.each(options,function(index,value){
            kit_pn.push(value.innerHTML)
        });
        if ( kit_pn.indexOf(value) >= 0){
            alert("KIT P/N "+ value+" is already present in List.");
            $("#new_pn_outdated_browser").val("");
            $("#kpnId").attr("disabled",false);
            $("#kpnId").prop('selectedIndex', 0);
            $("#link_to_newkit").trigger("click");
        }
        else {
            result = confirm($('#kpnId').val() + I18n.t('add_kit_dialog'));
            if (result){
                $("#stId").attr("disabled",false);
                $("#dpId").attr("disabled",false);
                if ($('#acId').val() != "" ) {
                    show_spinner();
                    $.ajax({
                        url: "/agusta/get_kit_part_details",
                        type: 'GET',
                        data: {
                            "aircraft_id": $('#acId').val(),
                            "kit_part_no": $("#new_pn_outdated_browser").val(),
                            "new_kit_flag": true
                        },
                        success: function (data) {
                            if (data == null) {
                                hide_spinner();
                                alert(I18n.t("rbo_down"));
                            }
                            else {
                                $("#kpnId").append("<option value="+$("#new_pn_outdated_browser").val()+">"+ $("#new_pn_outdated_browser").val()+"</option>");
                                $("#kpnId").val($("#new_pn_outdated_browser").val());
                                $("#new_pn_outdated_browser").attr("disabled",true);
                                $("#kpnId").attr("disabled",false);
                                remove_collapse();
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
                    alert(I18n.t('select_aircraft'));
                    return false;
                }
            }
            else {
                $("#new_pn_outdated_browser").val("");
                $("#kpnId").attr("disabled",false);
                $("#kpnId").prop('selectedIndex', 0);
                $("#link_to_newkit").trigger("click");
            }
        }
    }
}

function remove_collapse(){
    $("#link_to_newkit").html("<span class=\"glyphicon glyphicon-plus-sign\"></span>");
    $("#new_pn_outdated_browser").val("");
    $("#new_pn_outdated_browser").attr("disabled",false);
    $("#collapse_pn").removeClass("in");
}


//STOP METHOD FOR ADDING NEW KIT PN IN OUTDATED BROWSERS
function agustaResetFM() {
    $('#acId').val('');
    $("#kpnId").val("");
    $('#kpnId').attr("disabled",true);
    $("#stId").prop('selectedIndex', 0);
    $("#stId").attr("disabled", true);
    $("#dpId").prop('selectedIndex', 0);
    $("#dpId").attr("disabled", true);
    $(".main_order_div").remove();
}

function agustaCheckForm(value, type) {
    $(".alert").hide(500);
    if (type == "aircraft_id") {
        $("#kpnId").val("");
        $('#kpnId').attr("disabled", true);
        $("#stId").prop('selectedIndex', 0);
        $("#dpId").prop('selectedIndex', 0);
        $("#stId").attr("disabled", true);
        $("#dpId").attr("disabled", true);
        $(".main_order_div").remove();
        if (value > 0) {
            show_spinner();
            $.ajax({
                url: "/agusta/get_kit_details",
                type: 'GET',
                data: {
                    "aircraft_id": $('#acId').val()
                },
                success: function (data) {
                    var outdated_browser = data.browser
                    var kit_pn = data.kit_part_nos
                    hide_spinner();
                    if (data == null) {
                        alert(I18n.t("service_unavailable"));
                    }
                    else {
                        if (outdated_browser) {
                            $('#kpnId').html("<option value=\"\">" + I18n.t("select") + "</option>");
                            $.each(kit_pn, function(index, value) {
                                var opt = $('<option/>');
                                opt.attr('value', value);
                                opt.text(value);
                                opt.appendTo('#kpnId');
                            });
                            $("#link_to_newkit").show();
                        }
                        else {
                            $('#kpnId').autocomplete({
                                source : kit_pn,
                                minLength: 0,
                                scrollHeight: 220,
                                change: function(event,ui){
                                    if ( kit_pn.indexOf($('#kpnId').val()) >= 0){
                                        $("#add_kit_pn").hide();
                                        agustaCheckForm($('#kpnId').val(),'kit_part_number')
                                    }
                                    else {
                                        $(".main_order_div").remove();
                                        $.msgBox({
                                            type: "confirm",
                                            title: I18n.t('add_kit_pn'),
                                            content: $('#kpnId').val() + I18n.t('add_kit_dialog'),
                                            buttons : [
                                                {
                                                    type: "yes",
                                                    value: "Yes"
                                                },

                                                {
                                                    type: "no",
                                                    value: "No"
                                                }
                                            ],
                                            success: function(result){
                                                if (result == "Yes"){

                                                    $("#stId").attr("disabled",false);
                                                    $("#dpId").attr("disabled",false);
                                                    if ($('#acId').val() != "" && $('#kpnId').val() != "" && $('#kpnId').val() != undefined ) {
                                                        show_spinner();
                                                        $.ajax({
                                                            url: "/agusta/get_kit_part_details",
                                                            type: 'GET',
                                                            data: {
                                                                "aircraft_id": $('#acId').val(),
                                                                "kit_part_no": $('#kpnId').val(),
                                                                "new_kit_flag": true
                                                            },
                                                            success: function (data) {
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
                                                                alert("Unsuccessful Request");
                                                            }

                                                        });
                                                    }
                                                    else {
                                                        return false;
                                                    }
                                                }
                                                else {

                                                }
                                            }
                                        });
                                    }

                                }
                            }).on('focus', function(event) {
                                var self = this;
                                $(self).autocomplete("search", "");
                            });
                        }
                        $("#kpnId").prop('selectedIndex', 0);
                        $('#kpnId').attr("disabled", false);
                    }
                },
                error: function (data) {
                    hide_spinner();
                    alert("Unsuccessful Request");
                }
            });
        }
        else {
            $("#kpnId").val("");
            $('#kpnId').attr("disabled", true);
            $("#stId").prop('selectedIndex', 0);
            $("#dpId").prop('selectedIndex', 0);
            $("#stId").attr("disabled", true);
            $("#dpId").attr("disabled", true);
            $("#link_to_newkit").hide();
            agustaResetFM();
        }
    }
    else {
        $("#stId").attr("disabled", false);
        $("#dpId").attr("disabled", false);
    }
    if ($('#acId').val() != "" && $('#kpnId').val() != "" && $('#kpnId').val() != undefined ) {
        show_spinner();
        $.ajax({
            url: "/agusta/get_kit_part_details",
            type: 'GET',
            data: {
                "aircraft_id": $('#acId').val(),
                "kit_part_no": $('#kpnId').val()
            },
            success: function (data) {
                if (data == null) {
                    hide_spinner();
                    if ($("#browser").val() == "true"){

                    }
                    alert(I18n.t("rbo_down"));
                }
                else {
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
        return false;
    }
}

function agustaPopUpFormValidation() {
    if ($('#acId').val() == "" && $('#stId').val() == "" && $('#dpId').val() == "") {
        if($(".agusta_aircraft_id").children().length <= 2) {
            $(".agusta_aircraft_id").append("<label class=\"agusta_req_error\" >"+I18n.t('select_aircraft')+"</label>");
        }
        $("#acId:first").focus();
        //        alert(I18n.t("select_aircraft"));
        return false;
    }
    else if ($('#stId').val() == "") {
        if($(".agusta_station").children().length <= 2) {
            $(".agusta_station").append("<label class=\"agusta_req_error\" >"+I18n.t('select_station')+"</label>");
        }
        $("#stId:first").focus();
        return false;
    }
    else if ($('#dpId').val() == "") {
        if($(".agusta_discharge_point").children().length <= 2) {
            $(".agusta_discharge_point").append("<label class=\"agusta_req_error\" >"+I18n.t('select_discharge_point')+"</label>");
        }
        $("#dpId:first").focus();
        return false;
    }
    else {
        $("#aircraft_id").html($("#acId").val());
        $("#station_code").html($("#stId").val());
        $("#discharge_point").html($("#dpId").val());
        $('#addmore_parts_modal').modal();
        //$('#additionalPartID').prop("onclick", false);
    }
}


$(document).ready(function () {

    $("#inquiry_search_form").submit(function (event) {
        $(".alert").hide();
        $("#agusta_submit_search").hide();
        $("#agusta_search_record").show();
        if ( $("#search_by_select_value").prop("selectedIndex") != 0 ){
            if ( $("#search_val").val().replace(/\s/g,"") == "" ){
                if ($("#agusta_search_value").children().length <=2 ){
                    $("#agusta_search_value").append("<label class=\"search_val_error\" >"+I18n.t('select_search_by')+"</label>");
                    $("#search_val").focus();
                }
                $("#agusta_submit_search").show();
                $("#agusta_search_record").hide();
                event.preventDefault();
            }
        }
    });

    $("#search_by_select_value").change(function(e){
        $(".alert").hide();
        if ( $(this).prop("selectedIndex") == 0 ){
            $("#agusta_search_value").children().remove(".search_val_error");
        }
        else
        {
            if ( $("#search_val").val().replace(/\s/g,"") == "" ){
                if ($("#agusta_search_value").children().length <=2 ){
                    $("#agusta_search_value").append("<label class=\"search_val_error\" >"+I18n.t('select_search_by')+"</label>");
                }
            }
        }
    });

    $("body").on("keyup","#search_val",function(e){
        if (e.which >= 97 && e.which <= 122) {
            var newKey = e.which - 32;
            // I have tried setting those
            e.keyCode = newKey;
            e.charCode = newKey;
        }
        $(this).val(($(this).val()).toUpperCase());

        if( $(this).val() != ""){
            $("#agusta_search_value").children().remove(".search_val_error");
        }
    });


    if (I18n.locale == "it") {
        jQuery(function ($) {
            $.datepicker.regional['it'] = {
                closeText: 'Chiudi',
                prevText: 'Prec',
                nextText: 'Succ',
                currentText: 'Oggi',
                monthNames: ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
                    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'],
                monthNamesShort: ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu',
                    'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'],
                dayNames: ['Domenica', 'LunedÃ¬', 'MartedÃ¬', 'MercoledÃ¬', 'GiovedÃ¬', 'VenerdÃ¬', 'Sabato'],
                dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab'],
                dayNamesMin: ['Do', 'Lu', 'Ma', 'Me', 'Gi', 'Ve', 'Sa'],
                weekHeader: 'Sm',
                dateFormat: 'dd/mm/yy',
                firstDay: 1,
                isRTL: false,
                showMonthAfterYear: false,
                yearSuffix: ''
            };
            $.datepicker.setDefaults($.datepicker.regional['it']);
        });
    }

    $("body").on("change", ".select_motive", function (e) {
        if( $(this).prop("selectedIndex") > 0 ) {
            $(this).parent().children().remove(".select_agusta_motive");
        }
        if ($(this).prop("selectedIndex") > 8) {
            //            $(this).parent().next().children().attr("required", true);
            if ( $(this).parent().next().children().length <= 1 && $(this).parent().next().children(":first").val().replace(/\s/g,"") == ""){
                $(this).parent().next().children().addClass("note_check");
                $(this).parent().next().append("<label class=\"error_note\" >"+I18n.t('select_note')+"</label>");
            }

        }
        else {
            //            $(this).parent().next().children().attr("required", false);
            $(this).parent().next().children().removeClass("note_check");
            $(this).parent().next().children().remove("label.error_note");
        }
    });

    $("body").on("change",".agustaPart",function(e){
        if($(this).val().replace(/\s/g,"") != "" ){
            $(this).removeClass("note_check");
            $(this).parent().children().remove("label.error_note");
        }
        else
        {
            if ( $(this).parent().prev().children().prop("selectedIndex") > 8 ){
                $(this).addClass("note_check");
                if($(this).parent().children().length <= 1 ){
                    $(this).parent().append("<label class=\"error_note\" >"+I18n.t('select_note')+"</label>");
                }
            }
        }
    });

    $("body").on("keyup", ".agustaOrderQty,.new_part_qty", function (e) {
        if(this.value.match(/[^0-9]/g)){
            alert(I18n.t("numeric_qty"));
            $(this).val(0);
        }
    });



    $("body").on("keyup","#autocomplete_kpn,.new_kit_part, #kpnId,#new_pn_outdated_browser",function (e) {
        $(this).val(($(this).val()).toUpperCase());
        var value = $(this).val();
        var word = "";
        var regexp = /^[a-z0-9;_/-]+$/i;

        for (i = 0; i < value.length; i++) {
            x = value.charAt(i);
            if (regexp.test(x)) {
                word += x;
            }
            else {
                word = word.replace(x, "");
            }
        }
        $(this).val(word)

    });

    $("body").on("blur", ".new_kit_part", function (e) {
        if ($(this).val() == "") {
            alert(I18n.t("valid_part_number"));
        }
        else {
            if ($(this).val().replace(/\s/g,"") != "" ) {
                show_spinner();
                $.ajax({
                    url: "/agusta/add_part",
                    type: 'GET',
                    data: {
                        "partNo": $(this).val(),
                        "partCheck": "1",
                        "new_kit_flag": "true",
                        "current_object_id": $(this).attr('id')
                    },
                    success: function (data) {
                        $(this).val("");
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

    $("body").on("blur", ".agustaOrderQty", function (e) {
        // $(this).hasClass( "main_order_req" )
        var formId = this.form.id;
        var row_val = $(this);
        var data_details;
        if (formId == "") {
            data_details = {
                "partNo": $(this).parent().prev().prev().children().val(),
                "AgustaorderQty": this.value,
                "contractChec": "1"
            }
        } else {
            data_details = {
                "partNo": $(this).parent().prev().prev().children().val(),
                "AgustaorderQty": this.value
            }
        }

        if (parseInt(this.value) > 0) {
            if ($.isNumeric(this.value) == true) {
                show_spinner();
                $.ajax({
                    type: "GET",
                    url: "/agusta/get_contract_stock_check",
                    data: data_details,
                    success: function (data) {
                        hide_spinner();
                        if (data == null) {
                            alert(I18n.t("rbo_down"));
                        }
                        else {
                            if (data.errMsg != "") {
                                var browser_status = 0;
                                if (/MSIE (\d+\.\d+);/.test(navigator.userAgent))
                                {
                                    var ieversion=new Number(RegExp.$1);
                                    if (ieversion <=7 )
                                    {
                                        browser_status = 1;
                                    }
                                }
                                if(browser_status == 0) {
                                    $.msgBox({
                                        type: "confirm",
                                        title: I18n.t('contract_failed'),
                                        content: data.errMsg,
                                        buttons : [
                                            {
                                                type: "yes",
                                                value: "Yes"
                                            },

                                            {
                                                type: "no",
                                                value: "No"
                                            }
                                        ],
                                        success: function(result){
                                            if (result == "Yes"){

                                            }
                                            else {
                                                row_val.val(0);
                                            }
                                        }
                                    });
                                }
                                else {
                                    regex = /<br\s*[\/]?>/gi;
                                    result = confirm(data.errMsg.replace(regex,"\n"));
                                    if (result == true){

                                    }
                                    else {
                                        row_val.val(0);
                                    }
                                }
                                return false;

                            }
                            else {
                                $("#agusta_sendID").attr("disabled", false);
                            }
                        }

                    },
                    error: function (data) {
                        hide_spinner();
                        alert("Unsuccessful Request");
                    }

                });
            }

        }
        else {
            if (parseInt(this.value) == 0) {
                $(this).parent().next("td").children().remove(".select_agusta_motive");
                $("#agusta_sendID").attr("disabled", false);
            }
            else {
                $(this).parent().next("td").children().remove(".select_agusta_motive");
                $(this).val(0);
            }
        }

    });

    $("body").on("blur", ".new_part_qty", function (e) {
        if (parseInt(this.value) > 0) {

        }
        else {
            if (parseInt(this.value) == 0) {

                $("#agusta_sendID").attr("disabled", false);
            }
            else {

                $(this).val(0);
            }
        }

    });

    $("body").on("change", "#stId,#dpId,#kpnId,#acId", function (e) {
        $(this).parent().children().remove(".agusta_req_error");
    });
    $("body").on("change", "#agusta_order_select", function (e) {
        if($(this).prop("selectedIndex") >= 1) {
            $(this).parent().children().remove(".agusta_order_type_error");
        }
    });

    $("body").on("click", "#agusta_sendID", function (e) {
        show_spinner();
        $(this).hide();
        $("#agusta_submitorder").show();
        var dt = new Date();
        var time = dt.getHours() + ":" + dt.getMinutes() + ":" + dt.getSeconds();
        $("#localTime").attr("value", time)
        var empty_motive = [];
        $(".agustaOrderQty").each(function(index,value){
            if( parseInt($(this).val()) > 0 ){
                if ( $(value).parent().next("td").children("select").prop("selectedIndex") == 0 ){
                    empty_motive.push($(value).parent().next("td").children("select"));
                }
            }
        });
        var flag_part_number_empty = 0;
        var flag_part_qty_empty = 0;
        $(".new_kit_part").each(function(index,value){
            if( $(this).val() == "" ){
                flag_part_number_empty = 1;
            }
        });
        $(".new_part_qty").each(function(index,value){
            if( parseInt($(this).val()) <= 0 ){
                flag_part_qty_empty = 1;
            }
        });


        if ($('#acId').val() == "") {
            if($(".agusta_aircraft_id").children().length <= 2) {
                $(".agusta_aircraft_id").append("<label class=\"agusta_req_error\" >"+I18n.t('select_aircraft')+"</label>");
            }
            $("#acId:first").focus();
            $(this).show();
            $("#agusta_submitorder").hide();
            //            alert(I18n.t("select_aircraft"));
            hide_spinner();
            return false;
        }
        else if ($('#kpnId').val() == "") {
            if($(".agusta_kit_part_no").children().length <= 2) {
                $(".agusta_kit_part_no").append("<label class=\"agusta_req_error\" >"+I18n.t('select_kpn')+"</label>");
            }
            $("#kpnId:first").focus();
            $(this).show();
            $("#agusta_submitorder").hide();
            //            alert(I18n.t("select_kpn"));
            hide_spinner();
            return false;
        }
        else if ($('#stId').val() == "") {
            if($(".agusta_station").children().length <= 2) {
                $(".agusta_station").append("<label class=\"agusta_req_error\" >"+I18n.t('select_station')+"</label>");
            }
            $("#stId:first").focus();
            $(this).show();
            $("#agusta_submitorder").hide();
            //            alert(I18n.t("select_station"));
            hide_spinner();
            return false;
        }
        else if ($('#dpId').val() == "") {
            if($(".agusta_discharge_point").children().length <= 2) {
                $(".agusta_discharge_point").append("<label class=\"agusta_req_error\" >"+I18n.t('select_discharge_point')+"</label>");
            }
            $("#dpId:first").focus();
            $(this).show();
            $("#agusta_submitorder").hide();
            //            alert(I18n.t("select_discharge_point"));
            hide_spinner();
            return false;
        }

        else if ($(".new_kit_part").val() == ""){
            $(".new_kit_part").focus();
            $(this).show();
            $("#agusta_submitorder").hide();
            //            alert(I18n.t("select_discharge_point"));
            hide_spinner();
            return false;
        }
        else if ($(".note_check").length > 0){
            $(".note_check:first").focus();
            $(this).show();
            $("#agusta_submitorder").hide();
            hide_spinner();
            return false;
        }

        else if(empty_motive.length > 0) {
            if( empty_motive[0].parent().children().length <= 1) {
                empty_motive[0].parent().append("<label class=\"select_agusta_motive\" >"+I18n.t('select_agusta_motive')+"</label>");
            }
            empty_motive[0].focus();
            $(this).show();
            $("#agusta_submitorder").hide();
            hide_spinner();
            return false;
        }

        else if($("#agusta_order_select").prop("selectedIndex") < 1){
            if($(".agusta_order_type").children().length <= 1) {
                $(".agusta_order_type").append("<label class=\"agusta_order_type_error\" >"+I18n.t('select_order_type')+"</label>");
            }
            $("#agusta_order_select:first").focus();
            $(this).show();
            $("#agusta_submitorder").hide();
            hide_spinner();
            return false;
        }
        else if(flag_part_number_empty == 1){
            alert(I18n.t("valid_part_number"));
            $(this).show();
            $("#agusta_submitorder").hide();
            hide_spinner();
            return false;
        }
        else if(flag_part_qty_empty == 1){
            alert(I18n.t("part_qty"));
            $(this).show();
            $("#agusta_submitorder").hide();
            hide_spinner();
            return false;
        }

        else if ($('#acId').val() != "" && $('#kpnId').val() != "" && $('#stId').val() != "" && $('#dpId').val() != "") {
            var i;
            var error = [];
            $.each($("input[name='AgustaOrderQty[]']"), function (key, valueObj) {
                if (parseInt($(valueObj).val()) != "0") {
                    error.push(parseInt($(valueObj).val()) != "0");
                }
                else {

                }
            });
            if (jQuery.inArray(true, error)) {
                var browser_status = 0;
                if (/MSIE (\d+\.\d+);/.test(navigator.userAgent))
                {
                    var ieversion=new Number(RegExp.$1);
                    if (ieversion <=7 )
                    {
                        browser_status = 1;
                    }
                }
                if(browser_status == 0) {
                    hide_spinner();
                    $.msgBox({
                        title: I18n.t('enter_part'),
                        content: I18n.t('no_part')
                    });
                }
                else {
                    hide_spinner();
                    alert(I18n.t('no_part'));
                }
                $(this).show();
                $("#agusta_submitorder").hide();
                return false;
            }
            else {
                return true;
            }
        }
        else {
            return true;
        }
    });

    $("#agusta_restore_orderID").click(function (e) {
        agustaCheckForm();
        e.preventDefault();
    });

    $("body").on("click", "#additionalPartID", function () {
        if ($("#autocomplete_kpn").val() == "") {
            alert(I18n.t("valid_part_number"));
        }
        else {
            if ( $("#autocomplete_kpn").val().replace(/\s/g,"") != "" ) {
                show_spinner();
                $.ajax({
                    url: "/agusta/add_part",
                    type: 'GET',
                    data: {
                        "partNo": $("#autocomplete_kpn").val(),
                        "partCheck": "1"
                    },
                    success: function (data) {
                        $("#autocomplete_kpn").val("");
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

    $("body").on("click", "#newPartID", function () {
        var flag_for_part_number = 0;
        var flag_for_part_qty = 0;
        $.each($(".new_kit_part"), function (key, valueObj) {
            if ($(valueObj).val() == "") {
                flag_for_part_number = 1;
            }
        });
        $.each($(".new_part_qty"), function (key, valueObj) {
            if (parseInt($(valueObj).val()) == 0) {
                flag_for_part_qty = 1;
            }
        });
        if (flag_for_part_number == 1) {
            alert(I18n.t("valid_part_number"));
            return false;
        }
        else if(flag_for_part_qty == 1){
            alert(I18n.t("part_qty"));
            return false;
        }
        else{
            $("#table").each(function () {
                for (i=0; i<1; i++){
                    var tds = '<tr>';
                    var rowCount = $('#table tr').length - 1;
                    var rowVal = rowCount + 1;
                    tds += '<td align="left" style="text-align:left"> <input class="form-control new_kit_part" id="part_number_'+rowCount+'" name="part_number[]" type="text" size="10"></td>'+
                    '<td> <input class="form-control new_part_qty" id="AgustaOrderQtyReadOnly_'+rowCount+'" name="AgustaOrderQtyReadOnly[]" type="text" size="10" value="0"></td>' +
                    '<td> <input class="agustaOrderQty form-control" id="AgustaOrderQty_'+rowCount+'" name="AgustaOrderQty[]" type="text" value="0"></td>' +
                    '<td> <select class="select_motive form-control" id="motive_'+rowCount+'" name="motive[]">' +
                    '<option value="Select">Select</option>'+
                    '<option value="Job Card Shortage">Job Card Shortage</option><option value="Missing Part from Standard Kit">Missing Part from Standard Kit</option>'+
                    '<option value="Alternative for Job Card or Standard Kit Shortage">Alternative for Job Card or Standard Kit Shortage</option><option value="-/+ Length">-/+ Length</option>'+
                    '<option value="Lost or Damaged">Lost or Damaged</option><option value="Added After BOM Issued">Added After BOM Issued</option>'+
                    '<option value="Experimental unplanned requirement - not on Bar chart">Experimental unplanned requirement - not on Bar chart</option>'+
                    '<option value="Rework Not planned in bar chart">Rework Not planned in bar chart</option><option value="Installation from off site - i.e Brindisi fitters come to Vergiate to complete work">Installation from off site - i.e Brindisi fitters come to Vergiate to complete work</option>'+
                    '<option value="AW Subcontractor">AW Subcontractor</option><option value="Other">Other</option></select>'+
                    '<td><input class="PartNo form-control agustaPart" id="PartComment_'+rowCount+'" name="PartComment[]" type="text" value="" size="10"></td>'+
                    '<td><a id="delete_new_part" class="btn  btn-small delete_new_part"><i class="glyphicon glyphicon-remove"></i></a></td>';
                    tds += '</tr>';
                    $('tbody', this).append(tds);
                }
            });
            event.preventDefault();
        }
    });

    $("body").on('click','.delete_new_part', function(e) {
        $(this).parent().parent().remove();
    });

    $("body").on("click", ".delete_part", function () {
        $(this).parent().parent().remove();
    })

    $("#add_order_record").click(function () {
        $(".extra_order_req .extra_order_tr").each(function (i, row) {
            $(".main_order_req tr:last").after(row);
        });
        $("#autocomplete_kpn").val("");
        $("#order_close").trigger("click");
    });

    $("body").on("click","#link_to_newkit",function(){
        setTimeout(function() {
            if($("#new_pn_outdated_browser").is(":visible")){
                $("#link_to_newkit").html("<span class=\"glyphicon glyphicon-minus-sign\"></span>");
                $("#kpnId").prop('selectedIndex', 0);
                $("#kpnId").attr("disabled",true);
                $(".main_order_div").remove();
                $("#new_pn_outdated_browser").val("");
                $("#new_pn_outdated_browser").attr("disabled",false);
            }
            else {
                $("#link_to_newkit").html("<span class=\"glyphicon glyphicon-plus-sign\"></span>");
                $("#kpnId").prop('selectedIndex', 0);
                $("#kpnId").attr("disabled",false);
                $("#new_pn_outdated_browser").val("");
                $(".main_order_div").remove();
                $("#new_pn_outdated_browser").attr("disabled",false);
            }
        }, 1200);
    })

});