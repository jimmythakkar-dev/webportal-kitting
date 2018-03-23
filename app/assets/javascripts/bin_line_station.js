$(document).ready(function() {
    $('.cancel_button').click(function() {
        history.back();
    });

    $("#print_part").click(function(){
        $("#form_binlocator_update").attr('target', '_blank').submit().removeAttr('target');
        return false;
    });
});
