$(document).ready(function() {
    $(".selected_cup_ids").change(function(){
        $.post('/kitting/kit_details/store_selected_cup_ids', { cup_id: $(this).val(), checked: $(this).is(':checked'), label_for: "kits"});
    });

    $(".copy_selected_cup_ids").change(function(){
        $.post('/kitting/kit_details/store_selected_cup_ids', { cup_id: $(this).val(), checked: $(this).is(':checked'), label_for: "kit_copies"});
    });

    $(".pick_selected_cups").change(function(){
        $.post('/kitting/kit_details/store_selected_cup_ids', { cup_id: $(this).val(), checked: $(this).is(':checked'), label_for: "pick_ticket"});
    });
// Jquery to select all checkbox of print current box and remove after few sec.
    $(".container-fluid").on("click","#print_current_box",function(e){
        $(".pick_selected_cups").prop('checked',true);
        setTimeout(function(){
            $("#select_ids_:checked").removeAttr('checked');
        }, 2000);
    })
});