$(document).ready(function() {
    $("#stock_search_form").submit(function(){
        if($("#stock_transfer").val() == "") {
            alert("Please enter a Stock Transfer number to continue.");
            event.preventDefault();
        }

        if($("#control_number_stock").val() == "") {
            alert("Please enter a Control number to continue.");
            event.preventDefault();
        }
    });

})
