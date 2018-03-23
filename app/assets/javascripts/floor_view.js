// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {

    $("#part_submit").click(function(){

        if( $("#part_number").val() == '')
        {
            alert("Please enter a value for Part Number")
            return false;
        }
    });

    $("#location_submit").click(function(){

        if( $("#location").val() == '')
        {
            alert("Please enter a value for Location")
            return false;
        }
    });

    $("#print_order").click(function(){
        $("#form_submit_order").attr('target', '_blank').submit().removeAttr('target');
        return false;
    });




});

$("#floor_view_update").click(function(){
    var approvedBy = $("#approvedBy").val();
    var status = $("#status").val();
    var statusReason = $("#statusReason").val();
    if(approvedBy == "" )
    {
        alert("APPROVED BY must be filled out")
        return false;
    }
    if(status == "" || status == "Select Status")
    {
        alert("Approval Status must be filled out")
        return false;
    }
    if( status != "Approved")
    {
        if(statusReason == "" ){
            alert("Declined Reason must be filled out.")
            return false;
        }
        else{
            return true;
        }

    }
});

$("#days").change(function(){
    $('#loading').css('visibility','visible');
});
