// Place all the behaviors and hooks related to the matching controller here.
$(document).ready(function(){
    $("#panstock_action_history").click(function(){
        var approvedBy = $("#approvedBy").val();
        var status = $("#status").val();
        var OrderQty = $("#OrderQty").val();
        var statusReason = $("#statusReason").val();

        if(approvedBy == "" )
        {
            alert("APPROVED BY must be filled out")
            return false;
        }
        if(status == "" || status == "Select Status"  )
        {
            alert("Approval Status must be filled out")
            return false;
        }
        if(OrderQty == "")
        {
            alert("Missing Qty for part Approved")
            return false;
        }
        if(approvedBy != "" && $("#status").val() != "Approved"){
            {
                if(statusReason == "" ){
                    alert("Declined Reason must be filled out.");
                    return false;
                }
                else{
                    return true;
                }

            }
        }
    });

    $("#panstock_action_request").click(function(event){
        var send_to = $("#sendTo").val();
        var select_location = $("#selLocation").val();
        var originator = $("#Originator").val();
        var originator_phone = $("#OriginatorPhone").val();
        var foreman_name = $("#ForemanName").val();
        var foreman_phone = $("#ForemanPhone").val();
        if (send_to == "")
        {
            alert( "Missing Building/Ship To value." );
            $("#sendTo").focus();
            return false;
        }
        if (select_location == "")
        {
            alert( "Missing Line Station." );
            $("#selLocation").focus();
            return false
        }
        if (originator == "")
        {
            alert( "Missing Originator Name." );
            $("#Originator").focus();
            return false;
        }
        if (originator_phone == "")
        {
            alert( "Missing Originator Phone Number." );
            $("#OriginatorPhone").focus();
            return false;
        }
        if (foreman_name == "")
        {
            alert( "Missing Foreman Name." );
            $("#ForemanName").focus();
            return false;
        }
        if (foreman_phone == "")
        {
            alert( "Missing Foreman Phone Number." );
            $("#ForemanPhone").focus();
            return false;
        }
        var allPart = new Array();
        var allUom = new Array();
        for(var i=1;i<=15;i++)
        {
            if($("#PartNo_"+ [i]).val() != "")
            {
                allPart.push($("#PartNo_"+ [i]).val());
                allUom.push($("#um_"+ [i]).val());
            }
            var strPart = $("#PartNo_"+ [i]).val();
            var OrderQty = $("#OrderQty_"+ [i]).val();
            if(strPart != "")
            {
                if(OrderQty == "" || OrderQty == 0)
                {
                    alert("Missing or invalid Quantity on line "+ i +".");
                    $("#OrderQty_"+ i ).focus();
                    return false;
                }
            }
        }
        if(allPart.length <= 0)
        {
            alert( "Please enter a part number." );
            return false;
        }
        else{
            if (allPart.length == allUom.length){
                $.ajax({
                    type: "POST",
                    async: false,
                    dataType: 'JSON',
                    beforeSend: function(xhr) {show_spinner()},
                    url: "/panstock_requests/validate_contract" ,
                    data: {"PartNo" : allPart ,UOM :allUom },
                    success: function(data){
                        hide_spinner();
                        var error_link = null;
                        var error_type = null;
                        if (data.error.length > 0){
                            var contract_error = $("#contract_error");
                            contract_error.html("");
                            $.each(data.error, function(i)
                            {
                                if (data.error[i].indexOf("is invalid or is not on the contract") > 0){
                                    error_link =  error_link || data.error[i];
                                    error_type = "Part"
                                }else if(data.error[i].indexOf("has the invalid UM") > 0){
                                    error_link =  error_link || data.error[i]
                                    error_type = "UOM";
                                }else{
                                    error_link = null
                                }
                                var p = $('<p/>').appendTo(contract_error).text(data.error[i]);
                            });
                            if (error_type== "UOM"){
                                var invalid_part = error_link.split(" has")[0];
                                var invalid_uom  = error_link.split("be ")[1];
                                $(".PartNo").filter(function(index){
                                    return $(this).val() === invalid_part && $(this).parent().parent().find(".UM").val() != invalid_uom ;
                                }).focus();
                            }else if(error_type =="Part"){
                                var invalid_part = error_link.split(" is invalid")[0];
                                $(".PartNo").filter(function(index){
                                    return $(this).val() === invalid_part
                                }).focus();
                            }
                            else{
                            //    DO NOTHING
                            }
                            contract_error.show();
                            event.preventDefault();
                        }
                    },
                    error: function(){
                        hide_spinner();
                        alert("Something Went Wrong Contact KLX Representative.");
                        event.preventDefault();
                    }
                });
            }
            else{
                alert("Something Went Wrong Contact KLX Representative.");
                return false
            }

        }
    });

    $("#sendTo").change(function(){
        $("#selLocation").html("<option value=''>Select</option>");
    });

    $(".OrderQty").keyup(function() {
        var value =$(this).val();
        var word = "";
        var regexp = /[0-9]/;

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
        $(this).val(word)
    });

    $("#sendTo").change(function(){
        var s = $('<select/>');
        s.append($('<option/>').html());

        $("#selLocation").append(s);
    });
});

$("body").on("click","#panstock_bulk_submit",function(){
    var approved_by = $("#ApprovedBy").val()
    if(approved_by == "")
    {
        alert("APPROVED BY must be filled out");
        return false;
    }
});

$("body").on("click","#check_all",function() {
    $('input[type="checkbox"]').prop("checked", true);
});

$("body").on("click","#uncheck_all",function() {
    $('input[type="checkbox"]').removeAttr('checked');
});
$("body").on("change","#days",function(){
    $('#loading').css('visibility','visible');
});
