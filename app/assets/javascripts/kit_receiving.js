$("#save_receiving").click(function(){
	alert("The Kit has been Received");
});

function print_pick_sheet(){
    $('#cup_design').each(function(cups) {
        if($(this).find("table").attr('class') == 'table table-bordered binder'){
            var selected_qty;
            var demanded_qty;
            var selected_val;
            var demanded_val;
            $('#cup_design').each(function(cups) {
                $(this).find("table").each(function(table) {
                    $(this).find("tr").each(function(i,tr) {
                        selected_qty = $.trim($(this).find("td:last input.binder_filled_qty").val());
                        demanded_qty = $.trim($(this).find("td:last").prev().text());
                        if(selected_qty == "WL" || selected_qty == "S" || selected_qty == "E" || selected_qty == "0" || isNaN(selected_qty)){
                            selected_qty = selected_qty;
                            demanded_qty = demanded_qty;
                        }
                        else{
                            selected_qty = parseInt(selected_qty);
                            demanded_qty = parseInt(demanded_qty);
                        }

                        if(demanded_qty != selected_qty){
                            $(this).find("td:first").find('input[type=checkbox]').prop('checked', true);
                        }
                        else{
                            $(this).find("td:first").find('input[type=checkbox]').prop('checked', false);
                        }
                    });
                })
            })
        }
        else if($(this).find("div").find("div").attr('class') == 'gridster ready' || $(this).find("div").find("div").attr('class') == 'gridster gridster_screen_3_0 ready' || $(this).find("div").find("div").attr('class') == 'gridster gridster_screen_3_1 ready' || $(this).find("div").find("div").attr('class') == 'gridster gridster_screen_3_2 ready'){

            if ($(this).find("ul").attr('class') == 'filling_page') {
                $(this).find("li").each(function(li) {
                    if($(this).find("div").attr('class') == 'empty_filled_quantity' || $(this).find("div").attr('class') == 'partial_filled_quantity'){
                      $(this).find("div.btn_area").find('input[type=checkbox]').prop('checked', true);
                    }
                    else{
                      $(this).find("div.btn_area").find('input[type=checkbox]').prop('checked', false);
                    }
                });
            }
            
        }
        else{
            $(this).find("table").each(function(table) {
                $(this).find(".thumbnail").each(function(i,thumb) {
                    $(this).find("ul").each(function(ul) {
                        if($(this).find("li").length > 0){
                            if($(this).find("li").attr('class') == 'empty_filled_quantity' || $(this).find("li").attr('class') == 'partial_filled_quantity'){
                                $(thumb).find('input[type=checkbox]').prop('checked', true);
                            }
                            else
                            {
                                $(thumb).find('input[type=checkbox]').prop('checked', false);
                            }
                        }
                    })
                })
            })
        }
    })
}

$("#submitselected").click(function(e){
    print_pick_sheet();
    var count = $("input:checked").length;
    if (count==0){
        $.msgBox({
            title:"PRINT PICK SHEET",
            content:"There is No Partial or Empty Compartments to Print Pick Sheet.",
            type:"info"
        });
        e.preventDefault();
    };
});

$("#alternatebin").click(function(e) {
    print_pick_sheet();
    var selected_ids = [];
    var sort_by = $('input[name="sort_by"]:checked').val();
    if($("#select_ids_:checked").length > 0){
        $(':checkbox:checked').each(function(i){
            selected_ids[i] = $(this).val();
        });
    }
    $("#select_ids_for_alternate_").val(selected_ids);
    $("#sort_by").val(sort_by);
    $('#bincenter_select_modal').modal({"backdrop": "static"});
    return false;
});
$("#submitall").click(function(e){
    $('#cup_design').each(function(cups) {
        if($(this).find("div").find("div").attr('class') == 'gridster ready' || $(this).find("div").find("div").attr('class') == 'gridster gridster_screen_3_0 ready' || $(this).find("div").find("div").attr('class') == 'gridster gridster_screen_3_1 ready' || $(this).find("div").find("div").attr('class') == 'gridster gridster_screen_3_2 ready'){
            if ($(this).find("ul").attr('class') == 'filling_page') {
                $(this).find("li").each(function(li) {
                    $(this).find("div.btn_area").find('input[type=checkbox]').prop('checked', true);
                });
            }
        }
        else{
                $(this).find("table").each(function(table) {
                    $(this).find(".thumbnail").each(function(i,thumb) {
                        if($(thumb).find('input[type=checkbox]')){
                            $(thumb).find('input[type=checkbox]').prop('checked', true);
                        }
                    })
                })

        }
        return false;
    });
});   