$(document).ready(function(){
  $("[rel=tooltip]").tooltip({ placement: 'top'});
  $("#copy_button").click(function(event){
    if ($("#number_of_copies").val() == "") {
      alert("Please enter the Number of Copies");
      event.preventDefault();
    }
    else {
      var number_of_copies = $("#number_of_copies").val();
      var result = confirm("Are you sure want to create "+number_of_copies+" number of copy(s)");
        if(result == true) {
	  alert(number_of_copies +" copy(s) of this kit is created successfully");
	} 
	else{
	  $("#number_of_copies").val("");
	  event.preventDefault();
	}
     }
  });

  $("#number_of_copies").keyup(function() {
    var value =$(this).val();
    var word = "";
    var regexp = /[0-9]/;
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
        $(this).val(word)
    });

    $("#show_change").click(function(event){
      var kit_copy_id = $("#kit_copy_id").val();
      $.ajax({
        url: "/kitting/kit_copies/change_data/"+kit_copy_id,
        type: 'GET',
        onLoading: show_spinner(),
        success: function(data) {
          hide_spinner();
        }
      })
    });
    $("#print_internal_labels").on('click',function(){
        if($("#internal_label_type").prop("value") == ""){
            alert('Please Select Label Type');
            $("#internal_label_type").focus();
            return false
        }
    });
    $("#print_all_internal_labels").on('click',function(){
        if($("#all_internal_label_type").prop("value") == ""){
            alert('Please Select Label Type');
            $("#all_internal_label_type").focus();
            return false
        }
    });

    $("#manage_rfid").click(function(event){
        $('#manage_rfid_serial_number').modal({"backdrop": "static"});
    });

    $("#add_rfid").click(function(event) {
        if ($("#rfid_serial_number").val() == "") {
            alert("Please enter RFID Serial Number");
            return false;
        }
        else if($("#rfid_serial_number").val().length > 24){
            alert("RFID serial number should be maximum of 24 alpha numeric characters");
            return false;
        }
    });


    $("#rfid_serial_number").keyup(function() {
     var value =$(this).val();
     var word = "";
     var regexp = /[a-zA-Z0-9]/;

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
    $(this).val(word)
   });
});

$(function () {
    var $element = $('.show_inactive_message');
    setInterval(function () {
        $element.fadeIn(500, function () {
            $element.fadeOut(800, function () {
                $element.fadeIn(500)
            });
        });
    }, 1000);
});