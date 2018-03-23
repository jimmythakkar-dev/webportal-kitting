$(document).ready(function() {
    $("body").on("click",".mmt_cup_search_btn.btn",function(e){
        if($('#mmt_cup_search_box').val() != '' || $('#mmt_cup_search_box').val() == '0'){
            var cup_id = "";
            var cup_number ='';

            if ($('.gridster_container').length > 0){
                cup_id = $('.gridster_container ul li span.box-no:contains('+$('#mmt_cup_search_box').val()+')').parent().attr('id');
            }
            else{
                cup_id = $('div.cup_number_label:contains('+$('#mmt_cup_search_box').val()+')').parent().closest('div').find('ul').attr('data-id')
            }
            if(cup_id){
                //$(".popup_pages").removeClass("active");
                $.get('/kitting/cups/'+cup_id+'/build', function(data) {
                    $('#part_select_modal').modal({"backdrop": "static"});
                    $('#cup_id').val(cup_id);
                    $("#cup_number").val($('#mmt_cup_search_box').val());
                    $('#cup_number_info').text($('#mmt_cup_search_box').val());
                });
            }else{
                alert('Cup Number Not Valid');
            }
        }else{
            alert('Please Enter Cup Number');
        }
    });

    $("body").on("click",".edit-media-type a",function(e){
        $('.add-media-type-li').css('display','block');
        $('#add_media_type_submit').css('display','block');
        $(this).parent().css('display','none');
    });
    $("body").on("click",".hide-add-media-type-li",function(e){
        $('.add-media-type-li').css('display','none');
        $('#add_media_type_submit').css('display','none');
        $('.edit-media-type').css('display','block');
    });

    $("body").on("click","li .add-media-type",function(e){
        var kit_media_type_id = $("#add_design_kit_media_type_id").val();
        var action_btn = confirm("Are you sure to create a new Kit?");
        if( action_btn == true) {
            $.ajax({
                url: "/kitting/kits/add_media_type",
                type: 'GET',
                data: { "kit_id": $(this).attr('id'), "kit_media_type_id": kit_media_type_id },
                onLoading: show_spinner(),
                success: function (data) {
                    if (data.status == true) {
                        window.location.reload();
                        return true;
                    }
                    else {
                        hide_spinner();
                        $.msgBox({
                            title: "Error",
                            content: data.message.kit_number[0]
                        });
                        return false;
                    }
                },
                error: function (jqXHR, textStatus) {
                    hide_spinner();
                    alert("Please Try Again");
                }
            });
        }else{
            return false;
        }

    });

    $("body").on("click","li a.remove_media_type",function(e){
        var action_btn = confirm("Are you sure ?");
        if( action_btn == true){
            $.ajax({
                url: "/kitting/kits/remove_media_type",
                type: 'POST',
                data: { "sub_kit_id": $(this).attr('id') },
                onLoading: show_spinner(),
                success: function(data) {
                    if(data.status == true) {
                        window.location.reload();
                        return true;
                    }
                    else {
                        hide_spinner();
                        $.msgBox({
                            title:"Error",
                            content: data.message
                        });
                        return false;
                    }
                },
                error: function(jqXHR, textStatus) {
                    hide_spinner();
                    alert( "Please Try Again" );
                }
            });
        }else{
            return false;
        }
    });


    $(".popup").click(function() {
        $(this).add_part_popup();
    });

    $('#table_add').on('click','a.delete-part-add', function(e) {
        cup_id_for_delete = $('#cup_id_for_delete').val();
        kit_id = $('#kit_id').val();
        part_number_for_delete = $(this).parent().parent().find("input[name='part_number_for_delete[]']").val();
        $(this).parent().parent().remove();
        $.ajax({
            url: '/kitting/kits/delete_record',
            data: {"cup_id" : cup_id_for_delete, "part_number": part_number_for_delete,"kit_id": kit_id},
            type: "POST",
            dataType: 'json',
            success: function(msg){
            }
        });
    });
    $('#table').delegate('img.ImgDelete', 'click', function(e) {
        cup_id_for_delete = $('#cup_id_for_delete').val();
        kit_id = $('#kit_id').val();
        part_number_for_delete = $(this).parent().parent().find("input[name='part_number_for_delete[]']").val();
        $(this).parent().parent().remove();
        $.ajax({
            url: '/kitting/kits/delete_record',
            data: {"cup_id" : cup_id_for_delete, "part_number": part_number_for_delete,"kit_id": kit_id},
            type: "POST",
            dataType: 'json',
            success: function(msg){
            }
        });

    });

    $.extend($.ui.dialog.prototype.options, {
        closeText: "X"
    });

    $('#approval_button,#send_data_btn').click(function(event){
        $.ajax({
            url: "/kitting/kit_details/"+$('#kit_number').val()+"/get_kit_parts_count",
            type: 'GET',
            onLoading: show_spinner(),
            async: false,
            success: function(data) {
                hide_spinner();
                if(data.status) {
                    return true;
                }
                else {
                    count_parts = 0;
                    if(data.box){
                        alert( "There is no parts in any of the cups in Box no. "+data.box );
                    }
                    else{
                        alert( "There is no parts in any of the cups." );
                    }

                    event.preventDefault();
                    return false;
                }
            },
            error: function(jqXHR, textStatus) {
                hide_spinner();
                event.preventDefault();
                alert( "Please Try Again" );
            }
        });
    });
    $("#binder_button_cardex").click(function(){
        var notes = $("#notes").val();
        var description = $("#description").val();
        $("#kit_notes").val(notes);
        $("#kit_description").val(description);
    });

    //    For Binder Configuration


    $(".add_rows_to_table").on('click',function(event) {
        $(".table").each(function () {
            for (i=0; i<10; i++){
                var tds='';
                tds += '<tr>';
                var rowCount = $('.table tr').length - 1;
                var rowVal = rowCount + 1;
                tds += '<td><input class="kit_tray form-control" id="kit_tray_'+rowVal+'" name="kit_tray_'+rowVal+'" type="text" value="'+rowVal+'" disabled="disabled" ></td>'+
                    '<td><input class="non_contract_binder" id="non_contract_part_check_'+rowVal+'" name="non_contract_part_check_'+rowVal+'" type="checkbox" value="1"></td>'+
                    '<td><div class="row"><div class="col-sm-4"><label>Part Number</label></div><div class="col-sm-3"><label>Part Name</label></div><div class="col-sm-2"><label>QTY</label></div><div class="col-sm-3"><label>UOM</label></div></div>'+
                    '<div class="row"><div class="col-sm-4"><input autocomplete="off" class="form-control autofillparts binder_part_number_auto" id="part_number_auto_'+rowVal+'" name="part_number_auto_'+rowVal+'" required="required" type="text"></div><div class="col-sm-3"><input class="form-control" disabled="disabled" id="part_name_'+rowVal+'" name="part_name_'+rowVal+'" type="text">'+
                    '<input id="part_list" name="part_list" type="hidden" value=""></div><div class="col-sm-2"><input class="form-control demand_quantities" id="demand_quantity_'+rowVal+'" maxlength="4" name="demand_quantity_'+rowVal+'" required="required" type="text"></div>'+
                    '<div class="col-sm-3"><select class="form-control binder_uom" id="uom_'+rowVal+'" name="uom_'+rowVal+'"><option value="EA">EA</option><option value="LB">LB</option><option value="HU">HU</option><option value="TH">TH</option></select></div></div></td>'+
                    '<td><img class="delete_row" src="/assets/delete.gif"/></td>';
                tds += '</tr>';
//                $('tbody', this).append('<form accept-charset="UTF-8" action="/kitting/cup_parts/create" id="cup_part_data" method="post"></form>');
                $('tbody', this).append(tds);
            }
        });

        $(".non_contract_binder").on("change", function(event) {
            var current_id = this.id.match(/\d+/)[0];
            if($(this).is(':checked')) {
                $("#part_number_auto_"+current_id).val('');
                $("#part_name_"+current_id).val('');
//                $("#part_name_"+current_id).prop("disabled", false);
                $("#demand_quantity_"+current_id).val('');
            }
            else {
                $("#part_number_auto_"+current_id).val('');
                $("#part_name_"+current_id).val('');
                $("#part_name_"+current_id).prop("disabled", true);
                $("#demand_quantity_"+current_id).val('');
            }
        })

        event.preventDefault();
    });


    //  Add Part
    $('body').on('click', 'a.popup-binder', function(event) {
        var previous_part_number = $(this).parent().parent().prev().find("input[name='part_number']").val();
        var first_row = $(this).parent().parent().find("input[name='kit_tray[]']").val();
        var cup_number_sleev =$(this).parent().parent().find('td:first').find('input').val();
        $("#cup_number_sleev").val(cup_number_sleev)
        if (first_row != 1 && !previous_part_number){
            alert("Please enter part for previous cup")
            return false;
        }
        var cup_number =$(this).parent().parent().find('td:first').find('input').val()
        $('#cup_number_info').text(cup_number);
        $("#cup_number").val(cup_number);
        $('#part_select_modal_binder').modal('show');
    });


    //  Approval validation
    $('#binder_approval_button,#binder_button_cardex').click(function(event){

        var parts_arr = $(".binder_part_number_auto, .edit_binder_part_number_auto").map(function() {
            if ($(this).val() != "") {
                return $(this).val();
            }
        }).get();
//        var part_number = $.trim($(".table tbody tr td:nth-child(2)").text());
        if(parts_arr.length == 0 && $("#bincenter").val() != "" && $("#part_bincenter").val() != "")
        {

            $(function() {
                $( "<div>There is no parts added to any of the sleeves.</div>" ).dialog();
            });
            event.preventDefault();
        }
    });

    $(".demand_quantities,#demand_quantity,#actual_quantity").keyup(function() {
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

    $('#table').delegate("input[name='Quantities[]']", 'keyup', function() {
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


    $("#part_bincenter").change(function(){
        populate_bin();
    });
    $("#bincenter").change(function(){
        $("#kit_bin_center").val($("#bincenter").val());
    });
    $("#binder_button_cardex").click(function(){
        if($("#bincenter").val() == "")
        {
            alert("Please Select Kit Bin Center ")
            return false;
        }
//        if($("#part_bincenter").val() == "")
//        {
//            alert("Please Select Part Bin Center ")
//            return false;
//        }
    });
    $("#approve_kits").click(function(){
        if($("#bincenter").val() == "")
        {
            alert("Please Select Part Bin Center ")
            return false;
        }
        if($("#part_bincenter").val() == "")
        {
            alert("Please Select Part Bin Center ")
            return false;
        }
    });

    $("#approve_btn").click(function(){
        if($("#part_bincenter").val() == "")
        {
            alert("Please Select Part Bin Center ")
            return false;
        }
        if($("#bincenter").val() == "")
        {
            alert("Please Select Kit Bin Center ")
            return false;
        }
        populate_bin();
    });

    var value = $("#cup_number").val();
    $("#binder_table tr:eq("+(parseInt(value)+1)+") td:last a").click();
    $("#cup_parts"+(parseInt(value)+1)+"").next("p").children(".popup").click();
    $("#cup_parts"+(parseInt(value)+1)+"").find("a").first().click();
// JAVASCRIPT CODE TO REMOVE THE MESSAGE FROM PART ADD POP UP WHILE ENTERED PART NO IS CONVERTED TO CUST PN
    $("body").on("DOMSubtreeModified","#cust_pn_message",function(){
        setTimeout(function() {
            $("#cust_pn_message").css("display","none");
        }, 10000);
    });

    $(".modal-dialog").on("click","#close-add-part-popup",function(e){
        if($("#kit_type").val() != "configurable" ){
            var mmt_kit_id = $("#mmt_kit_id").val();
            var kit_id = $("#kit_id").val();
            var data = {}
            if (mmt_kit_id != ""){
                data.mmt_kit_id = mmt_kit_id
            }
            data.kit_id = kit_id
            $.ajax({
                url: '/kitting/kits/detail_design',
                data: data,
                type: "GET",
                dataType: "script",
                onLoading: show_spinner(),
                success: function(data){
                    hide_spinner();
                },
                error: function(data) {
                    hide_spinner();
                    window.location.reload();
                }
            });
        }
        else
        {
            var kit_number = $("#mmt_kit_number").val() == '' ? $("#kit_number").val() : $("#mmt_kit_number").val();
            $.ajax({
                url: '/kitting/kits/update_kit_layout',
                data: {"kit_number" : kit_number,"refresh_data" : true },
                type: "PUT",
                onLoading: start_configuring(),
                success: function(data){
                    stop_configuring();
                },
                error: function(data) {
                    stop_configuring();
                    window.location.reload();
                }
            });
        }
    })
});

function populate_bin(){
    var part_bincenter = $("#part_bincenter").val()
    $("#part_bin_center").val(part_bincenter);
    var part_num = $("#kit_number").val();
    var href5= "/kitting/kits/approve_kits?approved=true&kit_number="+part_num+"&part_bincenter="+part_bincenter;
    $("#approve_btn").attr("href",href5);
}