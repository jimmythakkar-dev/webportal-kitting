/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var photo_count = 1;

$( document ).ready(function() {
    $("#search_invoice_btn").click(function( event ) {
        if(part_no_validation() || date_validation()) {
            event.preventDefault();
        }
        else {
            $(".err_msg").html("");
            $("input").removeClass("invalid_input");
        }

    });

    $("#search_rma_btn").click(function( event ) {
        if(part_no_validation() || date_validation()) {
            event.preventDefault();
        }
        else {
            $(".err_msg").html("");
            $("input").removeClass("invalid_input");
//        $("#search_rma_form").attr("data-remote", "true");
//        $("#rma_search_results").html("Loading...");
//        $("#search_rma_btn").attr("disabled", "true");
        }
    });

    $("#part_number").keyup(function() {
        var value =$(this).val();
        var word = "";
        var regexp = /^[a-z0-9_/-]+$/i;

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

    $("body").on("blur", ".qty", function (e) {
        if(parseInt(this.value) > parseInt(this.max)) {
            $(".err_msg").html("Return Quantity should not be more than Ordered Quantity");
            event.preventDefault();
        }
        else{
            $(".err_msg").html("");
        }
    });

    $("#create_rma_form").submit(function( event ) {
        var quantities = $(".qty");
        var i;
        if($("#name").val() == ""){
            $(".err_msg").html("Please enter name");
            $("#name").addClass("invalid_input");
            event.preventDefault();
        }
        else if($("#reason_code").val() == ""){
            $(".err_msg").html("Please select reason code");
            $("#reason_code").addClass("invalid_input");
            event.preventDefault();
        }
        else if($("#email").val() == "" && $("#fax").val() == "") {
            $(".err_msg").html("Please enter either email address or fax");
            $("#email").addClass("invalid_input");
            event.preventDefault();
        }
        else if($("#reason").val() == ""){
            $(".err_msg").html("Please enter reason description");
            $("#reason").addClass("invalid_input");
            event.preventDefault();
        }
        else if ($("#name").val() != "" &&  $("#reason_code").val() != "" && ($("#email").val() != "" || $("#fax").val() != "") && $("#reason").val() != ""){
            var rma_qty_is_positive_value = 0;
            for(i = 0;i < quantities.length;i++) {
                var qty_obj = quantities[i];
                if (parseInt($("#" + qty_obj.id).val()) > 0){
                    rma_qty_is_positive_value = 1
                }
            }
            if (rma_qty_is_positive_value == 0){
                $(".err_msg").html("Please enter Return Qty");
                event.preventDefault();
            }
            else if(rma_qty_is_positive_value == 1){
                $(".err_msg").html("");
            }
        }
        else{
            $(".err_msg").html("");
            $("#email").removeClass("invalid_input");
            $("#reason_code").removeClass("invalid_input");
            $("#name").removeClass("invalid_input");
            $("#reason").removeClass("invalid_input");
        }

    });

    //datepicker
    $(".datepicker").datepicker();

    /*Checking for IE9 */
    if(document.documentMode == 9) {
        if($('#image1') != null) {
            $('#image1').fileupload({
                url: '/rma/save_img?format=js',
                sequentialUploads: true,
                dataType: 'script',
                replaceFileInput: false,
                start: function (e, data) {
                    $('#progress').html("Uploading...")
                },
                done: function (e, data) {
                    $('#progress').html("Done.")
                }
            });
        }
    } else {
        if (document.getElementById('image1') != null) {
            document.getElementById('image1').addEventListener('change', handleFileSelect, false);
        }
    }
});

function part_no_validation() {
    if($("#qty").val() != "") {
        if ($.isNumeric($("#qty").val()) == false || parseInt($("#qty").val()) < 0) {
            $(".err_msg").html("Please specify numeric Quantity greater than 0");
            $("#qty").addClass("invalid_input");
            return true;
        }
        else if ($("#part_number").val() == "") {
            $(".err_msg").html("Please specify part number along with Quantity");
            $("#part_number").addClass("invalid_input");
            return true;
        }
    }
    return false;
}

function date_validation() {
    var start_date = Date.parse($("#begin_date_rma").val());
    var end_date = Date.parse($("#end_date_rma").val());

    if($("#begin_date_rma").val() == "") {
        $(".err_msg").html("Please specify date range");
        $("#begin_date_rma").addClass("invalid_input");
        return true;
    }
    else if($("#end_date_rma").val() == ""){
        $(".err_msg").html("Please specify date range");
        $("#end_date_rma").addClass("invalid_input");
        return true;
    }
    else if($("#begin_date_rma").val() != "" || $("#end_date_rma").val() != ""){
        if(start_date > end_date) {
            $(".err_msg").html("End date should be greater than Start date");
            $("#end_date_rma").addClass("invalid_input");
            return true;
        }
    }

    return false;
}

function addMorePhotos(){
    photo_count++;
    var id_name = "image" + photo_count;
    var list_id = "list" + photo_count;
    var label_id = "label" + photo_count;
    var html = "<span id='upload_img"+ photo_count +"'><br /><hr/>";
    html += "<div id='lbl_div"+ photo_count +"'>"+ "Label" +": <input id="+ label_id + " type='text' name="+ label_id +" /></div>";
    html += "<br /><input id="+ id_name +" type='file' name="+ id_name +" accept='image/*' />";
    html += "<span id="+ list_id +"></span>";
    html += "<span id='remove_pic" + photo_count +"'></span></span>";
    $("#img_box").append(html);

    /*Checking for IE9 */
    if(document.documentMode == 9) {
        $('#' + id_name).fileupload({
            url: '/rma/save_img?format=js',
            sequentialUploads: true,
            dataType: 'script',
            replaceFileInput: false,
            start: function (e, data) {
                $('#progress').html("Uploading...")
            },
            done: function (e, data) {
                $('#progress').html("Done.")
            }
        });
    }
    else {
        document.getElementById(id_name).addEventListener('change', handleFileSelect, false);
    }
}

function handleFileSelect(evt) {
    var counter = evt.currentTarget.id.replace(/^\D+/g,"");
    var files = evt.target.files; // FileList object

    // Loop through the FileList and render image files as thumbnails.
    for (var i = 0, f; f = files[i]; i++) {

        // Only process image files.
        if (!f.type.match('image.*')) {
            continue;
        }

        var reader = new FileReader();

        // Closure to capture the file information.

        reader.onload = (function(theFile) {
            return function(e) {
                document.getElementById('list' + counter).innerHTML = ['<img class="thumb" src="',
                    e.target.result,'" title="', escape(theFile.name), '"/>'].join('');
                $("#remove_pic" + counter).html("<button type='button' class='btn glyphicon glyphicon-remove' onclick='remove_pic("+ counter +")'></button>");
            };
        })(f);


        // Read in the image file as a data URL.
        reader.readAsDataURL(f);
    }
}

function remove_pic(counter) {
    $("#upload_img" + counter).remove();
}

function getRMAdetails(rma_no) {
    $.ajax({
        type: "GET",
        url: "/rma/details/" + rma_no,
        onLoading: show_spinner(),
        success: function (data) {
            $("#rmadetails").html(data);
            hide_spinner();
            $('#rma_details').modal();
        }
    });
}

function next_page(page_num,event) {
    $("#invoice_search_results").html("Loading...");
    $.ajax({
        type: "GET",
        url: "/rma/show_invoices/" + page_num,
        success: function (data) {
            $("#invoice_search_results").html(data);

            $('.tablesorter').tablesorter({
                // this will apply the bootstrap theme if "uitheme" widget is included
                // the widgetOptions.uitheme is no longer required to be set
                theme : "bootstrap",

                widthFixed: true,

                headerTemplate : '{content} {icon}', // new in v2.7. Needed to add the bootstrap icon!

                // widget code contained in the jquery.tablesorter.widgets.js file
                // use the zebra stripe widget if you plan on hiding any rows (filter widget)
                widgets : [ "filter", "zebra" ],

                widgetOptions : {
                    // using the default zebra striping class name, so it actually isn't included in the theme variable above
                    // this is ONLY needed for bootstrap theming if you are using the filter widget, because rows are hidden
                    zebra : ["even", "odd"],

                    // reset filters button
                    filter_reset : ".reset"

                    // set the uitheme widget to use the bootstrap theme class names
                    // this is no longer required, if theme is set
                    // ,uitheme : "bootstrap"

                }
            });

            $.extend($.tablesorter, {
                // these classes are added to the table. To see other table classes available,
                // look here: http://twitter.github.com/bootstrap/base-css.html#tables
                table      : 'table table-bordered',
                header     : '', // give the header a gradient background
                footerRow  : '',
                footerCells: '',
                icons      : '', // add "icon-white" to make them white; this icon class is added to the in the header
                sortNone   : '',
                sortAsc    : '',
                sortDesc   : '',
                active     : '', // applied when column is sorted
                hover      : '', // use custom css here - bootstrap class may not override it
                filterRow  : '', // filter row class
                even       : '', // odd row zebra striping
                odd        : ''  // even row zebra striping
            });
        }
    });
}

function openPopUp(rmaNo,status,invoiceNo){
    $('#rma_no').val(rmaNo);
    $('#current_status').val(status);
    $('#invoice_no').val(invoiceNo);
    $('#send_mail_modal').modal({"backdrop": "static"});
}

function openPopUpForPrint(rma_no){
    $("p.alert").remove();
    $.ajax({
        type: "GET",
        url: "/rma/print_details/" + rma_no,
        onLoading: show_spinner(),
        success: function (data) {
            hide_spinner();
            if (data.status == "Approved"){
                $.msgBox({
                    title:"Packing Slip",
                    content: data.message,
                    type: "info"
                });
            }
            else {
                if(data.status=="SERVICE UNAVAILABLE"){
                    $.msgBox({
                        title:"Service Unavailable",
                        content: "Service Temporarily Unavailable",
                        type: "error"
                    });
                }else{
                    $.msgBox({
                        title:"Packing Slip",
                        content: "RMA is yet to be approved, packing slip cannot be generated."
                    });
                }
            }
        },
        error: function(data) {
            hide_spinner();
            $.msgBox({
                title:"Error While Fetching RMA STATUS",
                content: "Service Temporarily Unavailable",
                type: "error"
            });
        }
    });
}

$(function() {
  $("body").on("click",".paginate_ajax_open th a, .paginate_ajax_open .pagination a", function(){
    show_spinner();
    $.getScript(this.href);
    return false;
  });
});