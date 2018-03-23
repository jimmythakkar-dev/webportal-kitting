// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( "#show_password" ).on( "click", showPassword);
$( "#reset_password_save" ).on( "click", validatePassword);

//$('#confirm_password').bind("paste",function(e) {
//    e.preventDefault();
//});

function showPassword()
{
    var isChecked = $("#show_password").prop( "checked");

    if(isChecked){
        $(".password").prop('type', 'text');
        $(".control-label.label-show-password").text(I18n.t("hide_password"));
    }else{
        $(".password").prop('type', 'password');
        $(".control-label.label-show-password").text(I18n.t("show_password"));
    }
}

function validatePassword(e){
    if($("#user_name").val() == ''){
        alert(I18n.t('enter_user_name'));
        return false
    }
    if($("#current_password").val() == ''){
        alert(I18n.t('enter_user_current_password'));
        return false
    }
    if($("#new_password").val() == ''){
        alert(I18n.t('enter_user_new_password'));
        return false
    }
    if($("#confirm_password").val() == ''){
        alert(I18n.t('enter_user_confirm_password'));
        return false
    }
    if($("#new_password").val() == $("#confirm_password").val()){
        return true
    }
    else{
        alert(I18n.t("unmatched_password"));
        return false
    }
}