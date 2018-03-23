$(function() {
    $('#wo_due_date').datepicker({
        dateFormat: 'mm/dd/yy'
    });
});
$(document).ready(function(){
    $("#print_out_labels_for_wo, #print_in_labels_for_wo").on("click",function(){
        var ch_cnt = 0;
        ch_cnt = $("table .ch_td_for_wo").find("input[type=checkbox]:checked").length;
        if(ch_cnt > 0){
            return true
        }else{
            alert("Please check checkbox for bag label");
            return false
        }
    });
    $("#print_selected_wo").on("click",function(){
        var pick_cnt;
        pick_cnt = $("table .td_for_pct").find("input[type=checkbox]:checked").length
        if(pick_cnt > 0){
            return true
        }else{
            alert("Please select at least one KIT for pick sheet");
            return false
        }
    });

    $('form[name=due_date_update_form]').submit(function(e) {
        e.preventDefault();
        var id = $("form[name=due_date_update_form] #k_wo_id").val();
        var kit_no = $("form[name=due_date_update_form] #k_kit_no").val();
        var order_no = $("form[name=due_date_update_form] #k_wo_no").val();
        var date = $("form[name=due_date_update_form] #wo_due_date").val();


        $.msgBox({
            title: "Are You Sure",
            content: "Would you like to update all the kits having workorder " +order_no+ " ?" ,
            type: "confirm",
            buttons: [{ value: "Yes" }, { value: "No" }, { value: "Cancel"}],
            success: function (result) {
                if (result == "Yes") {
                    $.ajax({
                        url: "/kitting/kit_work_orders/" + id + "/update_due_date?due_date=" + date + "&update=all",
                        type: 'GET',
                        onLoading: show_spinner(),
                        success: function (data) {
                            hide_spinner();
                            alert( "Duedate updated successfully for all the kits");
                            window.location.reload();
                        },
                        error: function(data) {
                            hide_spinner();
                            alert( "Unable to Update");
                        }
                    });
                }
                else if(result == "No"){
                    $.ajax({
                        url: "/kitting/kit_work_orders/" + id + "/update_due_date?due_date=" + date + "&update=current",
                        type: 'GET',
                        success: function (data) {
                            hide_spinner();
                            alert('Duedate updated successfully for '+kit_no);
                            window.location.reload();
                        },
                        error: function(data) {
                            hide_spinner();
                            alert( "Unable to Update");
                        }
                    });
                }
                else{
                    return false
                }
            }
        });
    });
});