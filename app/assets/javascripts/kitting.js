// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  $("#validate_btn").click(function() {

    var kit_no_val =  $('#kit_number').val()
    if (kit_no_val==null || kit_no_val=="" )
    {
      alert("KIT NUMBER and PART NUMBER(s) must be filled out");
        $('#kit_number').focus();
      return false;
    }

//  make Kit number upper case
    $('#kit_number').val(function () {
      return this.value.toUpperCase();
    })

//  for part number check Tray, Qty, BinN is missing
    var rowCount = $('#table tbody tr').length - 1;
    var allEmpty = 1;
    for(i = 0; i < rowCount; i++)
    {
      strPart = $("#kit_part_number_"+i).val()
      Qty = $("#kit_quantity_"+i).val()
      BinN = $("#bin_number_"+i).val()
      Tray = $("#kit_tray_"+i).val()
      if ( strPart != '' )
        {
        var allEmpty = 0;
        if ( Qty == '' || Qty <= 0 || BinN == '' || Tray == '' || Tray == ' ')
          {
            alert( "Missing Tray/Qty/Bin Number for part " + strPart );
            $("#kit_quantity_"+i).focus();
            return false;
          }
        }
      else
        {
          $("#kit_quantity_"+i).val() == '';
        }
    }
    if (allEmpty == 1 )
    {
      alert( "Missing Part " );
      $("#kit_part_number_0").focus();
      return false;
    }
    return true;
  });

//    Here i Have Copy above fuction b'coz i want
//    rowCount = rowCount - 1 in above and rowCount =rowCount at here

  $("#validate_update_btn").click(function() {

    var kit_no_val =  $('#kit_number').val()
    if (kit_no_val==null || kit_no_val=="" )
    {
      alert("KIT NUMBER and PART NUMBER(s) must be filled out");
        $('#kit_number').focus();
      return false;
    }

//  make Kit number upper case
    $('#kit_number').val(function () {
      return this.value.toUpperCase();
    })

//  for part number check Tray, Qty, BinN is missing
    var rowCount = $('#table tbody tr').length;
    var allEmpty = 1;
    for(i = 0; i < rowCount; i++)
    {
      strPart = $("#kit_part_number_"+i).val()
      Qty = $("#kit_quantity_"+i).val()
      BinN = $("#bin_number_"+i).val()
      Tray = $("#kit_tray_"+i).val()
      if ( strPart != '' )
      {
        var allEmpty = 0;
        if ( Qty == '' || Qty <= 0 || BinN == '' || Tray == '' || Tray == ' ')
        {
          alert( "Missing Tray/Qty/Bin Number for part " + strPart );
          $("#kit_quantity_"+i).focus();
          return false;
        }
      }
      else
      {
        $("#kit_quantity_"+i).val() == '';
      }
    }
    if (allEmpty == 1 )
    {
      alert( "Missing Part " );
      $("#kit_part_number_0").focus();
      return false;
    }
    return true;
  });

  $(".kitting_part_number").click(function(event) {
    if (confirm("Delete Part Row?")) {
      $(this).closest('tr').remove();
      event.preventDefault();
    }
    return false;
  });

  $(".last_part_number").click(function(event){
    $("#table tr:last").remove();
    event.preventDefault();
  });

  $(".add_part_number").click(function(event) {
    $("#table").each(function () {
    var tds = '<tr>';
    var rowCount = $('#table tr').length - 1;
    var rowVal = rowCount + 1;
      tds += '<td> <input class="form-control" id="kit_tray_'+rowCount+'" name="kit_tray['+rowCount+']" type="text" value="'+rowVal+'"></td>'+
             '<td> <input id="kit_part_number_'+rowCount+'" name="kit_part_number['+rowCount+']" type="text" value=""></td>' +
             '<td> <input class="form-control" id="kit_quantity_'+rowCount+'" name="kit_quantity['+rowCount+']" type="text" value="1"></td>' +
             '<td> <select class="col-sm-12" id="um_'+rowCount+'" name="um['+rowCount+']">' +
                     '<option value="EA">EA</option><option value="LB">LB</option>'+
                     '<option value="HU">HU</option><option value="TH">TH</option></select>'+
             '<td> <input class="input-medium" id="bin_number_'+rowCount+'" name="bin_number['+rowCount+']" type="text" value=""></td>' +
             '<td>';


      tds += '</tr>';
      $('tbody', this).append(tds);
    });
    event.preventDefault();
  });

  $(".add_rows_to_table").click(function(event) {
    $("#table").each(function () {
      for (i=0; i<10; i++){
        var tds = '<tr>';
        var rowCount = $('#table tr').length - 1;
        var rowVal = rowCount + 1;
        tds += '<td> <input class="form-control" id="kit_tray_'+rowCount+'" name="kit_tray['+rowCount+']" type="text" value="'+rowVal+'"></td>'+
               '<td> <input id="kit_part_number_'+rowCount+'" name="kit_part_number['+rowCount+']" type="text" value=""></td>' +
               '<td> <input class="form-control" id="kit_quantity_'+rowCount+'" name="kit_quantity['+rowCount+']" type="text" value="1"></td>' +
               '<td> <select class="col-sm-12" id="um_'+rowCount+'" name="um['+rowCount+']">' +
               '<option value="EA">EA</option><option value="LB">LB</option>'+
               '<option value="HU">HU</option><option value="TH">TH</option></select>'+
               '<td> <input class="input-medium" id="bin_number_'+rowCount+'" name="bin_number['+rowCount+']" type="text" value=""></td>';


        tds += '</tr>';
            $('tbody', this).append(tds);
      }
    });
    event.preventDefault();
  });

  $("#kit_number,.part_number,.kit_tray,.bin_number,#kit_location").keyup(function() {
      var value =$(this).val();
      var word = "";
      var regexp = /[a-zA-Z0-9##\-\.\/]/;

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
$("#kit_number_search").keyup(function() {
      var value =$(this).val();
      var word = "";
      var regexp = /[a-zA-Z0-9##\-\.\ \%\_\/]/;

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

    $(".kit_quantity").keyup(function() {
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
});
