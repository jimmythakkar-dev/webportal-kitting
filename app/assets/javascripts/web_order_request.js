$( document ).ready(function() {
    $("#sikorsky,#variable_quantity_bin_order").submit(function(event){
        if($.trim($(".web_order_request_name").val()) == "" || $.trim($(".web_order_request_email").val()) == "" || $.trim($(".web_order_request_company").val()) == "") {
            event.preventDefault();
            if($.trim($(".web_order_request_name").val()) == "" ){
                alert("Please Enter Name to proceed");
                $(".web_order_request_name").focus();
            }else if ($.trim($(".web_order_request_email").val()) == ""){
                alert("Please enter Email to proceed");
                $(".web_order_request_email").focus();
            }else{
                alert("Please Enter Company Name.");
                $(".web_order_request_company").focus();
            }
        }
        else {
            var status = $(this).is("#sikorsky")
            table_rows = jQuery.grep($(".web_order_request_details"), function( row, index ) {
                if(status) {
                    return ( $.trim($(row).find(".web_order_request_pn").val()) != "" || $.trim($(row).find(".web_order_request_qty").val()) != "" || $(row).find(".web_order_request_sikorsky_oat").val() != "" ||  $.trim($(row).find(".web_order_request_deliver").val()) != "" );
                }
                else {
                    return ( $.trim($(row).find(".web_order_request_pn").val()) != "" || $.trim($(row).find(".web_order_request_qty").val()) != "" ||  $.trim($(row).find(".web_order_request_deliver").val()) != "" );
                }
            });
            if (table_rows.length == 0 ){
                event.preventDefault();
                alert("Enter a Part Number and its Details to Proceed");
            }
            else{
                $.each(table_rows, function( index, row ) {
                    var part_number = $.trim($(row).find(".web_order_request_pn").val());
                    var qty = $.trim($(row).find(".web_order_request_qty").val());
                    var deliver_to = $.trim($(row).find(".web_order_request_deliver").val());
                    if(status) {
                        var oat = $(row).find(".web_order_request_sikorsky_oat").val();
                        if (part_number == "" || qty == "" || oat == "" || deliver_to == "") {
                            event.preventDefault();
                            if (part_number == "" ){
                                alert("Enter Part Number");
                                $(row).find(".web_order_request_pn").focus();
                                return false;
                            }
                            else if(qty == ""){
                                alert("Enter Quantity");
                                $(row).find(".web_order_request_qty").focus();
                                return false;
                            }
                            else if(oat == "") {
                                var line = $(row).find("td:first").text();
                                alert("Select OAT for line no "+line+" .");
                                $(row).find(".web_order_request_oat").focus();
                                return false;
                            }
                            else{
                                alert("Enter a delivery point.");
                                $(row).find(".web_order_request_deliver").focus();
                                return false;
                            }
                        }
                    }
                    else{
                        if (part_number == "" || qty == "" || deliver_to == "") {
                            event.preventDefault();
                            if (part_number == "" ){
                                alert("Enter Part Number");
                                $(row).find(".web_order_request_pn").focus();
                                return false;
                            }
                            else if(qty == ""){
                                alert("Enter Quantity");
                                $(row).find(".web_order_request_qty").focus();
                                return false;
                            }
                            else{
                                alert("Enter a delivery point.");
                                $(row).find(".web_order_request_deliver").focus();
                                return false;
                            }
                        }
                    }
                });
            }
        }
        if ( !event.isDefaultPrevented() ) {
            var result = confirm("Are you sure that you want to submit the form at this time?");
            if (result == true){
                return true;
            }
            else{
                event.preventDefault();
            }
        }
    });
// JS CODE TO CONVERT PART NUMBERS ENTERED TO UPPERCASE
    $("body").on("keyup",".web_order_request_pn",function (e) {
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
// JS CODE TO CHECK FOR A VALID QUANTITY ONLY INTEGERS ALLOWED
    $("body").on("keyup", ".web_order_request_qty", function (e) {
        if(this.value.match(/[^0-9]/g)){
            $(this).val("");
            alert("Only numeric value allowed for quantity.")
        }
    });
//  JS CODE TO UNSET OAT AND DELIVERY LOCATIONS
    $("body").on("change",".web_order_request_sikorsky_ship_to",function(e){
        $(".web_order_request_sikorsky_oat").val("");
        $(".web_order_request_deliver").val("");
    });
});