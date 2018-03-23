function open_pop_up(kit_number, description, id){
    $('#kit_number').val(kit_number);
    $('#curr_desc').val(description);
    $('#kit_id').val(id);
    $('#edit_description_modal').modal({"backdrop": "static"});
}

$(document).ready(function() {
    $("#send_description_form").submit(function () {
        if ($("#new_desc").val() == "") {
            alert("Please enter Description.");
            event.preventDefault();
        }
    });

    $(".checked_kit_ids").change(function(){
        $.post('/kitting/admin/store_inactive_checked_status', { kit_id: $(this).val(), checked: $(this).is(':checked')});
    });

    $(".checked_kit_copy_ids").change(function(){
        $.post('/kitting/admin/store_inactive_checked_status', { kit_copy_id: $(this).val(), copy_checked: $(this).is(':checked')});
    });
});