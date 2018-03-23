// Added Clean method to Array for cleaning values
Array.prototype.clean = function(deleteValue) {
    for (var i = 0; i < this.length; i++) {
        if (this[i] == deleteValue) {
            this.splice(i, 1);
            i--;
        }
    }
    return this;
};

$(document).ready(function() {
    $('#search_remote_inventory').click(function(){
        if($('#part_number_inv').val() == ""){
            alert("You must enter a part number to continue.");
            $('#part_number_inv').focus();
            return false;
        }else{
            if($(this).hasClass("search_async")){
                $.ajax({
                    type: "POST",
                    url: "/remote_inventory/search_async",
                    data: { part_number:$('#part_number_inv').val(),stock_val: $("#parts_to_restock").val() },
                    onLoading: show_spinner(),
                    success: function(data) {
                        hide_spinner();
                    },
                    error: function(jqXHR, textStatus) {
                        hide_spinner();
                        alert( "Service Temporarily unavailable" );
                    }
                });
            }
        }
        return true;
    });
});

function addRemoveToCart(object,current_object){
    if (!$(current_object).attr("disabled")) {
        var stock_array = object.split("!");
        $(".restock_parts").css("display","block");
        $(current_object).attr("disabled","disabled");
        $("#restock_table").append("<tr class=\"restock_tr\"><td>"+stock_array[0]+"</td><td>"+stock_array[1]+"</td><td>"+stock_array[2]+"</td><td>"+stock_array[3]+"</td><td>"+stock_array[4]+"</td><td><p value="+object+" onclick='removeFromCart(this);' class='btn btn-default'><span class='glyphicon glyphicon-remove'></span></p></td></tr>");
        $(current_object).find("i").removeClass("glyphicon glyphicon-plus").addClass("glyphicon glyphicon-ok");
        var restocked_parts = $('#parts_to_restock').val().split(",").clean("");
        if (jQuery.inArray(object, restocked_parts) != 1){
            restocked_parts.push(object);
            $('#parts_to_restock').val(restocked_parts.join(","));
        }

    }

}

function removeFromCart(object){
    var value = $(object).attr("value");
    $("p.re_stock[value='"+value+"']").find("i").removeClass("glyphicon glyphicon-ok").addClass("glyphicon glyphicon-plus");
    $("p.re_stock[value='"+value+"']").removeAttr("disabled");
    $(object).parent().parent().remove();
    if($("#restock_table tr.restock_tr").length < 1 ){
        $(".restock_parts").css("display","none");
    }
    var restocked_parts = $('#parts_to_restock').val().split(",").clean("");
    if (jQuery.inArray(value, restocked_parts) != -1){
        restocked_parts.clean(value);
        $('#parts_to_restock').val(restocked_parts.join(","));
    }

}

function loadTxtPartNo(part_number){
    $('#part_number_inv').val(part_number);
}
function PrintElem(elem) {
    Popup(jQuery(elem).html());
}

function Popup(data) {
    var mywindow = window.open('', 'Restock', 'height=600,width=800');
    mywindow.document.write('<html><head><title></title>');
    mywindow.document.write('</head><body>');
    mywindow.document.write('<p style="text-align: center;">Remote Location Inventory</p><hr/>');
    mywindow.document.write('<div style="text-align: center;">');
    mywindow.document.write(data);
    mywindow.document.write('</div>');
    mywindow.document.write('</body></html>');
    mywindow.document.getElementsByClassName("filters")[0].parentNode.removeChild(mywindow.document.getElementsByClassName("filters")[0]);
    mywindow.document.getElementById("order_send_parts").parentNode.removeChild(mywindow.document.getElementById("order_send_parts"));
    mywindow.document.close();
    mywindow.print();
}
  

