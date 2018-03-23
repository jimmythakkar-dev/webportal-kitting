/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
$(document).ready(function() {
    var nowTemp = new Date();
    var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);

    var checkin = $('.start_datepick').datepicker({
        onRender: function(date) {
            return date.valueOf() < now.valueOf() ? 'disabled' : '';
        }
    }).on('changeDate', function(ev) {
        if (ev.date.valueOf() > checkout.date.valueOf()) {
            var newDate = new Date(ev.date)
            newDate.setDate(newDate.getDate() + 1);
            checkout.setValue(newDate);
        }
        checkin.hide();
        $('#end_date')[0].focus();
    }).data('datepicker');
    var checkout = $('.end_datepick').datepicker({
        onRender: function(date) {
            return date.valueOf() <= checkin.date.valueOf() ? 'disabled' : '';
        }
    }).on('changeDate', function(ev) {
        checkout.hide();
    }).data('datepicker');


    $('#tracking_report').click(function(event) {
        var d1 = new Date($("#begin_date").val());
        var d2 = new Date($("#end_date").val());
        if($("#begin_date").val() == "") {
            alert("Please select From date");
            $("#begin_date").focus();
            event.preventDefault();
        }
        else if($("#end_date").val() == ""){
            alert("Please select To date");
            $("#end_date").focus();
            event.preventDefault();
        }
        else if (($("#end_date").val() != "") && ($("#begin_date").val() != "")){
            if(!isDate($("#begin_date").val()) || !isDate($("#end_date").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if(d2 < d1){
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });

    $('#filling_report').click(function(event) {
        var d1 = new Date($("#begin_date2").val());
        var d2 = new Date($("#end_date2").val());
        if($("#begin_date2").val() == "") {
            alert("Please select From date");
            $("#begin_date2").focus();
            event.preventDefault();
        }
        else if($("#end_date2").val() == "") {
            alert("Please select To date");
            $("#end_date2").focus();
            event.preventDefault();
        }
        else if (($("#end_date2").val() != "") && ($("#begin_date2").val() != "")){
            if(!isDate($("#begin_date2").val()) || !isDate($("#end_date2").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if(d2 < d1) {
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });

    $('#turn_report').click(function(event) {
        var d1 = new Date($("#begin_date3").val());
        var d2 = new Date($("#end_date3").val());
        if($("#begin_date3").val() == "") {
            alert("Please select From date");
            $("#begin_date3").focus();
            event.preventDefault();
        }
        else if($("#end_date3").val() == "") {
            alert("Please select To date");
            $("#end_date3").focus();
            event.preventDefault();
        }
        else if(($("#end_date3").val() != "") && ($("#begin_date3").val() != "")){
            if(!isDate($("#begin_date3").val()) || !isDate($("#end_date3").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if(d2 < d1) {
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });

    $('#sos_report').click(function(event) {
        var sos_begin_date = new Date($("#sos_begin_date").val());
        var sos_end_date = new Date($("#sos_end_date").val());
        if($("#sos_begin_date").val() == "") {
            alert("Please select From date");
            $("#sos_begin_date").focus();
            event.preventDefault();
        }
        else if($("#sos_end_date").val() == "") {
            alert("Please select To date");
            $("#sos_end_date").focus();
            event.preventDefault();
        }
        else if(($("#sos_end_date").val() != "") && ($("#sos_begin_date").val() != "")){
            if(!isDate($("#sos_begin_date").val()) || !isDate($("#sos_end_date").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if (sos_end_date < sos_begin_date) {
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });

    $('#newly_designed_kits_report').click(function(event) {
        var newly_designed_kits_begin_date = new Date($("#newly_designed_kits_begin_date").val());
        var newly_designed_kits_end_date = new Date($("#newly_designed_kits_end_date").val());
        if($("#newly_designed_kits_begin_date").val() == "") {
            alert("Please select From date");
            $("#newly_designed_kits_begin_date").focus();
            event.preventDefault();
        }
        else if($("#newly_designed_kits_end_date").val() == "") {
            alert("Please select To date");
            $("#newly_designed_kits_end_date").focus();
            event.preventDefault();
        }
        else if(($("#newly_designed_kits_end_date").val() != "") && ($("#newly_designed_kits_begin_date").val() != "")){
            if(!isDate($("#newly_designed_kits_begin_date").val()) || !isDate($("#newly_designed_kits_end_date").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if (newly_designed_kits_end_date < newly_designed_kits_begin_date) {
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });

    $('#kit_fill_metrics_report').click(function(event) {
        var kit_fill_metrics_begin_date = new Date($("#kit_fill_metrics_begin_date").val());
        var kit_fill_metrics_end_date = new Date($("#kit_fill_metrics_end_date").val());
        if($("#kit_fill_metrics_begin_date").val() == "") {
            alert("Please select From date");
            $("#kit_fill_metrics_begin_date").focus();
            event.preventDefault();
        }
        else if($("#kit_fill_metrics_end_date").val() == "") {
            alert("Please select To date");
            $("#kit_fill_metrics_end_date").focus();
            event.preventDefault();
        }
        else if(($("#kit_fill_metrics_end_date").val() != "") && ($("#kit_fill_metrics_begin_date").val() != "")){
            if(!isDate($("#kit_fill_metrics_begin_date").val()) || !isDate($("#kit_fill_metrics_end_date").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if (kit_fill_metrics_end_date < kit_fill_metrics_begin_date) {
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });
    $('#charts_image').click(function(event) {
        var kit_fill_metrics_begin_date = new Date($("#kit_fill_metrics_begin_date").val());
        var kit_fill_metrics_end_date = new Date($("#kit_fill_metrics_end_date").val());
        if($("#kit_fill_metrics_begin_date").val() == "") {
            alert("Please select From date");
            $("#kit_fill_metrics_begin_date").focus();
            event.preventDefault();
        }
        else if($("#kit_fill_metrics_end_date").val() == "") {
            alert("Please select To date");
            $("#kit_fill_metrics_end_date").focus();
            event.preventDefault();
        }
        else if(($("#kit_fill_metrics_end_date").val() != "") && ($("#kit_fill_metrics_begin_date").val() != "")){
            if(!isDate($("#kit_fill_metrics_begin_date").val()) || !isDate($("#kit_fill_metrics_end_date").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if (kit_fill_metrics_end_date < kit_fill_metrics_begin_date) {
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });

    $('#returned_parts_details_report').click(function(event) {
        var returned_parts_begin_date = new Date($("#returned_parts_begin_date").val());
        var returned_parts_end_date = new Date($("#returned_parts_end_date").val());
        if($("#returned_parts_begin_date").val() == "") {
            alert("Please select From date");
            $("#returned_parts_begin_date").focus();
            event.preventDefault();
        }
        else if($("#returned_parts_end_date").val() == "") {
            alert("Please select To date");
            $("#returned_parts_end_date").focus();
            event.preventDefault();
        }
        else if(($("#returned_parts_end_date").val() != "") && ($("#returned_parts_begin_date").val() != "")){
            if(!isDate($("#returned_parts_begin_date").val()) || !isDate($("#returned_parts_end_date").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if (returned_parts_end_date < returned_parts_begin_date) {
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });

    $('#kit_work_order_status_report').click(function(event) {
        var kit_status_begin_date = new Date($("#kit_status_begin_date").val());
        var kit_status_end_date = new Date($("#kit_status_end_date").val());
        if($("#kit_status_begin_date").val() == "") {
            alert("Please select From date");
            $("#kit_status_begin_date").focus();
            event.preventDefault();
        }
        else if($("#kit_status_end_date").val() == "") {
            alert("Please select To date");
            $("#kit_status_end_date").focus();
            event.preventDefault();
        }
        else if(($("#kit_status_end_date").val() != "") && ($("#kit_status_begin_date").val() != "")){
            if(!isDate($("#kit_status_begin_date").val()) || !isDate($("#kit_status_end_date").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if (kit_status_end_date < kit_status_begin_date) {
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });

    $('#delivery_report').click(function(event) {
        var delivery_begin_date = new Date($("#delivery_begin_date").val());
        var delivery_end_date = new Date($("#delivery_end_date").val());
        if($("#delivery_begin_date").val() == "") {
            alert("Please select From date");
            $("#delivery_begin_date").focus();
            event.preventDefault();
        }
        else if($("#delivery_end_date").val() == "") {
            alert("Please select To date");
            $("#delivery_end_date").focus();
            event.preventDefault();
        }
        else if(($("#delivery_end_date").val() != "") && ($("#delivery_begin_date").val() != "")){
            if(!isDate($("#delivery_begin_date").val()) || !isDate($("#delivery_end_date").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if (delivery_end_date < delivery_begin_date) {
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });

    $('#crib_delivery_report').click(function(event) {
        var crib_delivery_begin_date = new Date($("#crib_delivery_begin_date").val());
        var crib_delivery_end_date = new Date($("#crib_delivery_end_date").val());
        if($("#crib_delivery_begin_date").val() == "") {
            alert("Please select From date");
            $("#crib_delivery_begin_date").focus();
            event.preventDefault();
        }
        else if($("#crib_delivery_end_date").val() == "") {
            alert("Please select To date");
            $("#crib_delivery_end_date").focus();
            event.preventDefault();
        }
        else if(($("#crib_delivery_end_date").val() != "") && ($("#crib_delivery_begin_date").val() != "")){
            if(!isDate($("#crib_delivery_begin_date").val()) || !isDate($("#crib_delivery_end_date").val())){
                alert("Please enter valid date");
                event.preventDefault();
            }
            else if (crib_delivery_end_date < crib_delivery_begin_date) {
                alert("Please select To date greater than From date");
                event.preventDefault();
            }
        }
    });


    $('#begin_date,#end_date,#begin_date2,#end_date2,#begin_date3,#end_date3,#sos_begin_date,#sos_end_date,#newly_designed_kits_begin_date,#newly_designed_kits_end_date,#kit_fill_metrics_begin_date,#kit_fill_metrics_end_date,#returned_parts_begin_date,#returned_parts_end_date,#kit_status_begin_date,#kit_status_end_date,#delivery_begin_date,#delivery_end_date').on("change",function(event){
        var begin_date = $('#begin_date').val().split("/").join("");
        var end_date = $('#end_date').val().split("/").join("");
        var begin_date2 = $('#begin_date2').val().split("/").join("");
        var end_date2 = $('#end_date2').val().split("/").join("");
        var begin_date3 = $('#begin_date3').val().split("/").join("");
        var end_date3 = $('#end_date3').val().split("/").join("");
        var sos_begin_date = $('#sos_begin_date').val().split("/").join("");
        var sos_end_date = $('#sos_end_date').val().split("/").join("");
        var newly_designed_kits_begin_date = $('#newly_designed_kits_begin_date').val().split("/").join("");
        var newly_designed_kits_end_date = $('#newly_designed_kits_end_date').val().split("/").join("");
        var kit_fill_metrics_begin_date = $('#kit_fill_metrics_begin_date').val().split("/").join("");
        var kit_fill_metrics_end_date = $('#kit_fill_metrics_end_date').val().split("/").join("");
        var returned_parts_begin_date = $('#returned_parts_begin_date').val().split("/").join("");
        var returned_parts_end_date = $('#returned_parts_end_date').val().split("/").join("");
        var kit_status_begin_date = $('#kit_status_begin_date').val().split("/").join("");
        var kit_status_end_date = $('#kit_status_end_date').val().split("/").join("");
        var delivery_begin_date = $('#delivery_begin_date').val().split("/").join("");
        var delivery_end_date = $('#delivery_end_date').val().split("/").join("");
        var href= "/kitting/kit_filling_tracking_history?end_date="+end_date+"&begin_date="+begin_date;
        var href1= "/kitting/order_fulfillment_tracking?end_date2="+end_date2+"&begin_date2="+begin_date2;
        var href2= "/kitting/turn_count?end_date3="+end_date3+"&begin_date3="+begin_date3;
        var newly_designed_kits_href= "/kitting/newly_designed_kits?newly_designed_kits_end_date="+newly_designed_kits_end_date+"&newly_designed_kits_begin_date="+newly_designed_kits_begin_date;
        var sos_href= "/kitting/sos_pn_sortage?sos_end_date="+sos_end_date+"&sos_begin_date="+sos_begin_date;
        var kit_fill_metrics_href= "/kitting/kit_fill_metrics?kit_fill_metrics_end_date="+kit_fill_metrics_end_date+"&kit_fill_metrics_begin_date="+kit_fill_metrics_begin_date;
        var returned_parts_href= "/kitting/returned_parts_details?returned_parts_end_date="+returned_parts_end_date+"&returned_parts_begin_date="+returned_parts_begin_date;
        var kit_status_href= "/kitting/kit_work_order_status?kit_status_end_date="+kit_status_end_date+"&kit_status_begin_date="+kit_status_begin_date;
        var delivery_href= "/kitting/delivery?delivery_end_date="+delivery_end_date+"&delivery_begin_date="+delivery_begin_date;


        $("#tracking_report").attr("href",href);
        $("#filling_report").attr("href",href1);
        $("#sos_report").attr("href",sos_href);
        $("#turn_report").attr("href",href2);
        $("#newly_designed_kits_report").attr("href",newly_designed_kits_href);
        $("#kit_fill_metrics_report").attr("href",kit_fill_metrics_href);
        $("#returned_parts_details_report").attr("href",returned_parts_href);
        $("#kit_work_order_status_report").attr("href",kit_status_href);
        $("#delivery_report").attr("href",delivery_href);
    });

    $('#crib_delivery_begin_date,#crib_delivery_end_date').on("change",function(e){
        var crib_delivery_begin_date = $('#crib_delivery_begin_date').val().split("/").join("");
        var crib_delivery_end_date = $('#crib_delivery_end_date').val().split("/").join("");
        var crib_delivery_href= "/kitting/crib_delivery?crib_delivery_end_date="+crib_delivery_end_date+"&crib_delivery_begin_date="+crib_delivery_begin_date;
        $("#crib_delivery_report").attr("href",crib_delivery_href);
    });

    function isDate(txtDate) {
        var objDate,  // date object initialized from the ExpiryDate string
            mSeconds, // txtDate in milliseconds
            day,      // day
            month,    // month
            year;     // year
        // date length should be 10 characters (no more no less)
        if (txtDate.length !== 10) {
            return false;
        }
        // third and sixth character should be '/'
        if (txtDate.substring(2, 3) !== '/' || txtDate.substring(5, 6) !== '/') {
            return false;
        }
        // extract month, day and year from the txtDate (expected format is mm/dd/yyyy)
        // subtraction will cast variables to integer implicitly (needed
        // for !== comparing)
        month = txtDate.substring(0, 2) - 1; // because months in JS start from 0
        day = txtDate.substring(3, 5) - 0;
        year = txtDate.substring(6, 10) - 0;
        // test year range
        if (year < 1000 || year > 3000) {
            return false;
        }
        // convert ExpiryDate to milliseconds
        mSeconds = (new Date(year, month, day)).getTime();
        // initialize Date() object from calculated milliseconds
        objDate = new Date();
        objDate.setTime(mSeconds);
        // compare input date and parts from Date() object
        // if difference exists then date isn't valid
        if (objDate.getFullYear() !== year ||
            objDate.getMonth() !== month ||
            objDate.getDate() !== day) {
            return false;
        }
        // otherwise return true
        return true;
    }
});