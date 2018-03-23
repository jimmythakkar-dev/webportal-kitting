//check filled quantity in wl or number
function fill_kit(val){
    var value = $("#filled_quantity").val();
    var word = "";
    var regexp = /[WLwlSsEe0-9]/;

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
    $("#filled_quantity").val(word.toUpperCase())
}

// open popup for filling quantity on create filling page
$(".fill-pop-up").click(function() {
    var pop_up_id = $(".fill-pop-up").attr("id");
    var cup_id = $(this).attr('data-id');
    var lastChar = '';
    if($('#kit_type').val() != 'configurable' && $('#kit_type').val() != 'multi-media-type'){
        lastChar = $(this).prev('ul').attr("id").substr($(this).prev('ul').attr("id"));
        lastChar = lastChar.replace ( /[^\d.]/g, '' );
    }
    else{
        lastChar = $(this).parent().parent().children('span.box-no').text();
    }
    var url_string = initialize_value(pop_up_id);
    $('#kit_cup_number').val(cup_id);
    $('#cup_number_count').val(lastChar);
    $('#table-create tbody').remove();
    $.ajax({
        url: url_string,
        type: 'GET',
        data: "cup_id="+cup_id,
        success: function(data) {
            if(data.error){
                $.msgBox({
                    title:"Error Occured",
                    content:"This Kit Filling is Shipped/Send to Stock/Cancelled; Contact Your KLX Administrator",
                    type:"info"
                });
                window.location = "/kitting/kit_copies"
            }
            else{
                $.each(data, function(i,item) {
                    $.each(item, function(j,value) {
                        fill_table(i,value,$('#table-create'));
//                        var select_value = fill_select_option( value[2]);
                        if(value[2] == "Water-Level" || value[2] == "WL" )
                        {
                            var warning = "Note:Please enter WL for Water-Level OR S for Short OR E for Empty"
                            $("#note").html(warning).css("color","red")
                        }
                        if(value[2] != "Water-Level" && value[2] != "WL")
                        {
                            var number_warning = "Note:Please enter value less then or equal to " +value[2]
                            $("#note").html(number_warning).css("color","red")
                        }
                    });
                });
                $('#fill-pop-up_modal').modal({"backdrop": "static"});
            }
        }
    });
});
// open popup for filling quantity on edit filling page
$(".edit-fill-pop-up").click(function() {

    var pop_up_id = $(".edit-fill-pop-up").attr("id");
    var cup_id = $(this).attr('data-id');
    var lastChar ='';
    if($('#kit_type').val() != 'configurable'){
        lastChar = $(this).prev('ul').attr("id").substr($(this).prev('ul').attr("id"));
        lastChar = lastChar.replace ( /[^\d.]/g, '' );
    }
    else{
        lastChar = $(this).parent().parent().parent().children('span.box-no').text();
    }
    var url_string = initialize_value(pop_up_id);
    $('#kit_cup_number').val(cup_id);
    $('#cup_number_count').val(lastChar);
    $('#table-edit tbody').remove();
    $.ajax({
        url: url_string,
        type: 'GET',
        data: "cup_id="+cup_id,
        success: function(data) {
            if(data.error){
                $.msgBox({
                    title:"Error Occured",
                    content:"This Kit Filling is Shipped/Send to Stock/Cancelled; Contact Your KLX Administrator",
                    type:"info"
                });
                window.location = "/kitting/kit_copies"
            }
            else{
                $.each(data, function(i,item) {
                    $.each(item, function(j,value) {
                        fill_table(j,value,$('#table-edit'));
//                        var select_value = fill_select_option(value[2]);
                        $('select.mySelect#filled_quantity_'+ j +'').val(value[3])

                    });
                });
                $('#edit-fill-pop-up_modal').modal({"backdrop": "static"});
            }
        }
    });

});

// select ajax url for $(".edit-fill-pop-up").click function
function initialize_value(id)
{
    var url_str = "";
    if (id == 'kit_filling_create'){
        url_str = "/kitting/kit_filling/"+$("#kit_filling_id").val()+"/search_parts";
    }
    else if (id == 'kit_filling_edit'){
        url_str = "/kitting/kit_filling/"+$("#kit_filling_id").val()+"/edit_search_parts";
    }
    else if (id == 'configurable-edit'){
        url_str = "/kitting/kit_filling/"+$("#kit_filling_id").val()+"/edit_search_parts";
    }
    return url_str;
}
function fill_select_option(val) {
    var selectValues = []
    for (var index = 1; index <= val; index++)
    {
        selectValues.push(index) ;
    }
    $.each(selectValues, function(k, value) {
        $('select.mySelect')
            .append($("<option></option>")
                .val(value)
                .text(value));
    });
}
function fill_table(j,value,table_id) {
    if(value[2] == "Water-Level" || value[2] == "WL" )
    {
        var warning =
            '<tr>' +
            '<td colspan="3" id="note" style="color: red; text-align: left">Note:Enter WL for Water-Level OR S for Short OR E for Empty</td> ' +
            '</tr>'

    }
    else
    {
        var warning =
            '<tr>' +
            '<td colspan="3" id="note" style="color: red; text-align: left"> Note:Please Enter value Less then or equal to ' +value[2]+'</td> ' +
            '</tr>'
    }
    if(value[3] == undefined) {
        var quantity_input = '<td><input id="filled_quantity" class="form-control filled_qty" name="filled_quantity[]"   onkeyup="fill_kit(this);" type="text" required="required" data-id="2">'
    }
    else {
        var quantity_input = '<td><input id="filled_quantity" class="form-control filled_qty" name="filled_quantity[]"   value='+ value[3] +'  onkeyup="fill_kit(this);" type="text" required="required" data-id="2">'
    }

    strToAdd = '<tr>' +
        '<input id="cup_part_id_"'+ j +'" name="cup_part_id[]" value='+ value[0] +' class="form-control" type="hidden" readonly = true />' +
        '<td><input id="part_numbers_"'+ j +'" name="part_numbers[]" value='+ value[1] +' class="form-control" type="text" readonly = true /></td>' +
        '<td><input id="actual_quantities_'+j +'" name="actual_quantities[]" value='+ value[2] +' class="form-control demand_qty" type="text" readonly = true data-id= "1"/></td>' +
        quantity_input +
        '</td>' +
        '</tr>'+
        warning   ;

    table_id.append(strToAdd);
}

if($('#kit_type').val() == 'configurable'){
    $(".gridster ul.filling_page li div.block_area div").each(function (i) {
        var dmd_qty = $(this).prev("span").text().replace(/\(|\)/g, '');
        var fld_qty = $(this).text().replace(/\(|\)/g, '');
        if(dmd_qty != ''){
            check_filled_color(dmd_qty,fld_qty,$(this).parent());
        }
    });
}
else{
    $("ul.filling_page li div").each(function (i) {
        var dmd_qty = $(this).prev("span").text().replace(/\(|\)/g, '');
        var fld_qty = $(this).text().replace(/\(|\)/g, '');
        if(dmd_qty != ''){
            check_filled_color(dmd_qty,fld_qty,$(this).parent());
        }
    });
}
// change cup color according to the filled quantity
function check_filled_color(demand_qty,filled_qty,div_tag){
    if(demand_qty == "Water-Level"  || demand_qty == "WL" || filled_qty == "WL" || filled_qty == 'S' ||filled_qty == ''){
        demand_qty = demand_qty;
        filled_qty = filled_qty;
    }
    else{
        demand_qty = parseInt(demand_qty);
        filled_qty = parseInt(filled_qty);
    }

    if(demand_qty == filled_qty || (demand_qty == "Water-Level" && filled_qty == "WL")){
        div_tag.attr('class','full_filled_quantity');
    }
    else{
        if(filled_qty == 'S' || filled_qty == 'E'){
            if(filled_qty == 'S' ){
                div_tag.attr('class','partial_filled_quantity');
            }
            else if(filled_qty == 'E' ){
                div_tag.attr('class','empty_filled_quantity');
            }

        }
        else{
            if((filled_qty > 0 && filled_qty < demand_qty)){
                div_tag.attr('class','partial_filled_quantity');
            }
            else if(filled_qty == 0 || filled_qty == null || filled_qty == ''){
                div_tag.attr('class','empty_filled_quantity');
            }
            else{

            }
        }
    }
}

$("table.tablesorter.filling_table tr td:nth-child(4)").each(function(){
    var filled_status = $(this).html();
    $("table.tablesorter tbody tr:nth-child(odd) > td").css({'background-color':'transparent'});
    if (filled_status == "Full"){

        $(this).parent('tr').attr('class','full_filled_quantity')
    }
    else if (filled_status == "Partial"){
        $(this).parent('tr').attr('class','partial_filled_quantity')
    }
    else if (filled_status == "Empty"){
        $(this).parent('tr').attr('class','empty_filled_quantity')
    }
});

// ---------------------------------------------------------------------------------------------------------
$("#kit_filling_location_id").change(function(){
    var location  = $("#kit_filling_location_id option:selected").text();
    var sos_loc   = "SOS Queue";
    var send_to_stock_loc  = "Send to Stock";
    var ship_invoice_loc = "Ship/Invoice";
    remove_values();
    $('#order_status').css('visibility','hidden');
    $('#save_filling').attr('disabled','disabled');
    if ( location == sos_loc || location == send_to_stock_loc || location == ship_invoice_loc){
        $('#loading').css('visibility','visible');
        $('#order_status').css('visibility','visible').text('Checking Open Order...');
        $.ajax({
            url: "/kitting/kit_filling/"+$("#kit_filling_id").val()+"/find_open_order",
            type: 'GET',
            success: function(data) {
                if (data.error){
                    alert("This KitFilling is Cancelled/Send to Stock/Shipped , Check with KLX Administrator !!!");
                    window.location = "/kitting/kit_copies"
                }
                else
                {
                    if(location == ship_invoice_loc){
                        if(data.kit_order_no != '' && data.errCode == '0'){
                            order_filling(data,location);
                        }else if(data.kit_order_no == ''){
                            $.msgBox({
                                title:"No Open Order Exists",
                                content:"Please select Other Queue.",
                                type:"info"
                            });
                        }
                    }
                    else if(location == send_to_stock_loc){
                        if (data.bailment_flag == true) {
                            $("#kit_filling_location_id").prop("selectedIndex",0);
                            $.msgBox({
                                title:"KIT COPY EXIST",
                                content:"KIT COPY ALREADY PRESENT IN INVENTORY, SELECT ANOTHER QUEUE.",
                                type:"info"
                            });
                        }
                        else if(data.kit_order_no != '' && data.errCode == '0'){
                            order_filling(data,location);
                        }else if(data.kit_order_no == ''){
                            var option_1 = $("<option value='Send to Bailment'>Send to Bailment</option>");
                            $('#kit_order_number').append(option_1);
                            var option_2 = $("<option value='-'>-</option>");
                            $('#kit_scan_code').append(option_2);
                        }
                    }
                    else if(location == sos_loc){
                        if(data.kit_order_no != '' && data.errCode == '0'){

                            $.msgBox({
                                title: "Are You Sure",
                                queue: location,
                                content: "There is open order for this kit, Do you still want to send it to "+ location +"?",
                                type: "confirm",
                                buttons: [{ value: "Yes" }, { value: "No" }],
                                success: function (result,queue) {
                                    if (result == "No") {
                                        $.msgBox({
                                            title:"Open Order Exits",
                                            content:"Please select Other Queue.",
                                            type:"info"
                                        });
                                    }
                                    else{
                                        remove_values();
                                        $("#kit_filling_location_id option:selected").text();
                                    }
                                }
                            });
                        }
                    }
                    $('#loading').css('visibility','hidden');
                    $('#save_filling').removeAttr('disabled');
                    (data.kit_order_no == '' ? $('#order_status').css('visibility','visible').text('No Open Order'):$('#order_status').css('visibility','visible').text('Open Order Exist'));
                }
            }
        });
    }
    else{
        remove_values();
        $('#save_filling').removeAttr('disabled');
    }
});

function order_filling(data_order_number,loc)
{
    var order_no;
    var i;
    var scan_code;

    if(loc == "Send to Stock"){
        var option_1 = $("<option value='Send to Bailment'>Send to Bailment</option>");
        $('#kit_order_number').append(option_1);
    }
    $.each(data_order_number.kit_order_no,function(i) {
        order_no = data_order_number.kit_order_no[i];
        var option = $("<option value='" + order_no + "'>" + order_no + "</option>");
        $('#kit_order_number').append(option);
    });
    $('#kit_order_number_list').val(data_order_number.kit_order_no);

    if(loc == "Send to Stock"){
        var option_2 = $("<option value='-'>-</option>");
        $('#kit_scan_code').append(option_2);
    }
    $.each(data_order_number.kit_scan_code,function(i) {
        scan_code = data_order_number.kit_scan_code[i];
        var option = $("<option value='" + scan_code + "'>" + scan_code + "</option>");
        $('#kit_scan_code').append(option);
    });
    $('#kit_scan_code_list').val(data_order_number.kit_scan_code);
}
function remove_values(){
    $("#kit_filling_location_id option:selected").text();
    $("#kit_order_number option").remove();
    $("#kit_scan_code option").remove();
    $('#kit_order_number_list').val('');
    $('#kit_scan_code_list').val('');
}

$("#kit_order_number").on('change',function(){
    var location  = $("#kit_filling_location_id option:selected").text();
    var order  =    $("#kit_order_number option:selected").text();
    $("#kit_scan_code option")[$("#kit_order_number option:selected").index()].selected= true
//    $('#order_status').css('visibility','visible').text('Send kit to '+ location + ', With Order No.:' + order);
});
$("#save_filling").click('change',function(){
    if($("#kit_filling_location_id,#kit_filling_location option:selected").val() == '0'){
        alert('Please select Queue');
        return false;
    }
//    if($("#kit_order_number_list").val() != ''){
//        alert('Open order exist, Please select other queue');
//        return false;
//    }
    var queue_status = $("#kit_filling_location_id option:selected").text();
    if(queue_status == "SOS Queue" || queue_status == "Send to Stock" || queue_status == "Ship/Invoice")
    {
        if( $("#show_message").css("display") == "block")
        {
            alert("Please acknowledge changes implemented")
            return false;
        }
        else
        {
            return true;
        }
    }
    $("#kit_scan_code option")[$("#kit_order_number option:selected").index()].selected= true

});
// ---------------------------------------------------------------------------------------------------------

$("#kit_filling_send_to_ship").click(function() {
    $.ajax({
        url: "/kitting/kit_filling/reset_filled_kit/id="+$(this).attr("data-id"),
        type: 'GET',
        data: "data="+$(this).attr("data-id"),
        success: function(data) {
            alert("Filled Kit Send to Shipment");
            window.location.reload();
        },
        error: function(jqXHR, textStatus) {
            alert( "Unsuccessful Request: " + textStatus );
        }
    });
});


$("#cup_filling_btn").click(function(event){
    var status = [];
    $(".demand_qty").each(function( index ) {
        if($(this).val() == "Water-Level" || $(this).val() == "WL")
        {
            var filled_qty = $(".filled_qty:eq("+index+")").val().toUpperCase();
            if(filled_qty == "WL" || filled_qty == "S" || filled_qty == "E")
            {   $(".filled_qty:eq("+index+")").val().toUpperCase();
                status.push(true)
            }
            else
            {
//            alert("Please enter a valid Quantity")
                status.push(false)
            }
        }
        if($(this).val() != "Water-Level" && $(this).val() != "WL")
        {
            var number_filled_qty = $(".filled_qty:eq("+index+")").val()
            var demand_qty =$(this).val()

            if(parseInt(number_filled_qty) <= parseInt(demand_qty) && number_filled_qty >= 0)
            {
                status.push(true)
            }
            else
            {
                status.push(false)
            }
        }
    });
    if ($.inArray(false, status) == -1) {
        return true
    }
    else{
        alert("Please enter a valid Quantity");
        return false
    }
});

setInterval(function() {

    $("#show_message").load("/kitting/kit_filling/kit_status/"+$("#kit_id").val(),function(data){
        if(data == "Kit changed")
        {
            $("#show_message").css("display", "block");
            close_btn = '<button id= close_status_alert class="change_implement_btn">Changes Implemented</button>'
            $("#show_message").html("Kit BOM has been modified recently. <a id='kit_bom' data-toggle='modal hide fade',data-target ='#myModal', style='margin-left:100px;'>Show Change Data</a> " + close_btn).animate({left:"+=10px"}).animate({left:"-5000px"})
            $("#close_status_alert").attr('title', 'Implement kit BOM changes');
            $("#show_message").fadeOut(800).fadeIn(50);
            $.ajax({
                url: "/kitting/kit_filling/get_cup_changes/"+$("#kit_id").val(),
                type: 'GET',
                success: function(cups_array) {
                    for(i=0;i<cups_array.length;i++)
                    {
                        if (typeof $('#kit_type').val() != 'undefined' && $("#kit_type").val() == "configurable"){
                            $("li[id='" + cups_array[i] + "'] > div").eq(0).addClass('bluecups');
                        }
                        else{
                            $("ul[data-id='" + cups_array[i] + "']").parent().parent().addClass('bluecups');
                        }
                    }
                }
            });
            $("#kit_bom").click(function() {
                $.ajax({
                    url: "/kitting/kit_filling/change_data/"+$("#kit_id").val(),
                    type: 'GET',
                    onLoading: show_spinner(),
                    success: function(data) {
                        hide_spinner();
                    }
                });
            });
            $("#close_status_alert").on("click",function(){
                $("#show_message").hide();
                $.ajax({
                    url: "/kitting/kit_filling/kit_copy_status_update/"+$("#kit_id").val(),
                    type: 'GET',
                    onLoading: show_spinner(),
                    success: function(data) {
                        hide_spinner();
                        window.location.reload();
                    }
                });
            });
        }
        else
        {
            $("#show_message").css("display","none");
        }
    });
}, $("#kit_version_check_interval").val());


$(".toggle_data").click(function() {
    var cup_id = $(this).attr('data-id');
    var fill_qty = $("#filled_qty_"+cup_id).html();
    var filled_quantity = new Array(fill_qty);
    var cup_part_id = new Array($("#cup_part_"+cup_id).html());
    var kit_filling_id = $("#kit_filling_id").val();
    var id = $("#kit_id").val();
    var kit_number = $("#kit_number").val();
    $.ajax({
        url: "/kitting/kit_receiving/"+id+"/toggle_data",
        type: 'POST',
        data: {"id":id,"cup_identity":cup_id,"kit_filling_id":kit_filling_id,"kit_number":kit_number,"cup_part_id":cup_part_id,"filled_quantity":filled_quantity},
        onLoading: show_spinner(),
        success: function(data) {
        },
        failure: function(){
            hide_spinner();
            alert("Something Went Wrong contact with your KLX Administrator.")
        },
        error: function(jqXHR, textStatus) {
            hide_spinner();
            alert( "Something Went Wrong contact with your KLX Administrator." );
        }
    });
});

$('.binder_filled_qty').blur(function(event) {
    var cup_id = $(this).closest("tr").find('td:eq(0)').find('input:eq(0)').val();
    if(cup_id.indexOf('-') === -1){
      cup_id = cup_id
    }
    else{
      cup_id = cup_id.split("-")
      cup_id = $.trim(cup_id[1]);
    }
    var member_data = $.parseJSON($("td#"+cup_id).parents("tr").find("td input.member_data").first().val());
    var prev_quantity = $("td#"+cup_id).parents("tr").find("td input.prev_quantity").first().val()
    var status = [];
    var demand_quantity = $.trim($(this).closest('tr').find('td:eq(2)').text());
    var filled_quantity = $(this).val().toUpperCase();
    var kit_filling_id = member_data.kit_filling_id;
    if(demand_quantity == "Water-Level" || demand_quantity == "WL")
        {
            if(filled_quantity == "WL" || filled_quantity == "S" || filled_quantity == "E")
            {   
                status.push(true)
            }
            else
            {
                $(this).val("E");
                status.push(false)
            }
        }
    if(demand_quantity != "Water-Level" && demand_quantity != "WL")
        {
            if(parseFloat(filled_quantity) <= parseFloat(demand_quantity) && filled_quantity >= 0)
            {
                status.push(true)
            }
            else
            {
                $(this).val(0);
                status.push(false)
            }
        }
    if ($.inArray(false, status) == -1) {
        $("#save_filling").attr("disabled", false);
//        console.log(filled_quantity);
//        console.log(prev_quantity);
        if(filled_quantity != prev_quantity) {
            $.ajax({
                   url: "/kitting/kit_filling/"+kit_filling_id+"/kit_filling_edit",
                   type: 'POST',
                   data: { "member_data": member_data, "filled_qty": filled_quantity },
                   onLoading: show_spinner(),
                   success: function(data) {
                        hide_spinner();
                    },
                    error: function(jqXHR, textStatus) {
                        hide_spinner();
                        alert( "Unsuccessful Request: ");
                    }
                });
        }

    }
    else{
        $("#save_filling").attr("disabled", true);
        alert("Please enter a valid Quantity")
        return false;
    }
});