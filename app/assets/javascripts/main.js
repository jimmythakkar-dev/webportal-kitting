// This code was in application.js earlier. It contains methods common to all modules

if($(".gridster.gridster_screen_3_0").length > 0){
    $(".container").css("width","1300px")
}
if($("table.admin-table").length > 0){
    $(".container").css("width","1200px")
}

$(document).ready(function() {

    $("a:contains(Log Out)").click(function(e){
        if ($("#toPopup").is(":visible")){
            var result = confirm("Your BOM report is being Generated, Are you Sure you want to Log out ? ");
            if(result == true) {
                return true
            }
            else {
                return false
            }
        }
        else
        {
            return true
        }
    });

    var status = $("#report_status").attr("val");
    if (status != undefined){
        if (status.length > 0) {
            $("#toPopup").fadeIn(0500);
        }
        else {
            $("#toPopup").fadeOut("normal");
        }
    }

    setInterval(function() {
        var stat = $("#report_status").attr("val");
        if (stat != undefined && stat.length > 0 ){
            $.get("/kitting/kit_details/"+stat,function(data,status){
            });
        }
    }, 5000);

    $("#ui-datepicker-div").hide();

    $("img.ui-datepicker-trigger").click(function() {
        $("#ui-datepicker-div").show();
    });

    $(".print_all").click(function(e){
        $checkBoxes = $('input[type="checkbox"]');
        $checkBoxes.prop('checked', false);
    });

    $("#display_menu").on("click",function(){
//        $('#side_menu').toggle(function(e){
            if ($("#main_page").attr("class") == "col-sm-12"){
//                $("#main_page").attr("class","");
                $("#main_page").removeClass("col-sm-12");
//                $('#side_menu').removeClass("col-sm-1");

                $("#main_page").addClass("col-sm-9");
                $('#side_menu').addClass("col-sm-3");
                $('#side_menu').css("display","inline");


                $("#display_menu").attr("class","btn btn-default glyphicon glyphicon-chevron-right");

            }
            else {
//                $("#main_page").attr("class","col-sm-9");
                $("#main_page").removeClass("col-sm-9");
                $('#side_menu').removeClass("col-sm-3");

                $("#main_page").addClass("col-sm-12");
//                $('#side_menu').addClass("col-sm-1");
                $('#side_menu').css("display","none");

                $("#display_menu").attr("class","btn btn-default glyphicon glyphicon-chevron-left");

            }

//        });
    });

    $(".search_cup").submit(function (evt) {
        var cup_id = $.makeArray( );
        if(typeof $('#kit_type').val() != 'undefined' && $('#kit_type').val() == "configurable"){
            $.each($("span.part_block"), function(index, value) {
                if ($.trim($(this).text()) == $("#part_number_search").val()){
                    cup_id.push( $(this).closest("li").attr("id") );
                }
            });
        }
        else if(typeof $('#kit_type').val() != 'undefined' && $('#kit_type').val() == "binder"){
            $.each($("span.part_block"), function(index, value) {
                if ($.trim($(this).text()) == $("#part_number_search").val()){
                    cup_id.push( $(this).closest("tr").find('td:eq(0)').find('input:eq(0)').val());
                }
            });
        }
        else{
            $.each($("span.part_block"), function(index, value) {
                if ($(this).text() == $("#part_number_search").val()){
                    cup_id.push( $(this).closest("ul").attr("data-id") );
                }
            });
        }

        if(typeof $('#kit_type').val() != 'undefined' && $('#kit_type').val() == "configurable"){
            if (cup_id.length == 1) {
                $(".cup_list").html("");
                if(typeof $("a[data-id="+cup_id[0]+"]").val() == 'undefined'){
                    $("p[data-id="+cup_id[0]+"]").trigger("click");
                }
                else{
                    $("a[data-id="+cup_id[0]+"]").trigger("click");
                }
            }
            else{
                $(".cup_list").html("");
                if(cup_id.length != 0) {
                    $.msgBox({
                        title:"CUP STATUS",
                        content:"You have More than One Cup with part No. "+ $("#part_number_search").val()+". select from the List of Cups to Fill.",
                        type:"info"
                    });
                    var sel = $("<select class= \"form-control\" onchange = \"cup_record(this.value);\">").appendTo('.cup_list');
                    sel.append($("<option>").attr('value',"").text("Select A Cup"));
                    $.each( cup_id, function( index, value ){
                        if (typeof $("a[data-id="+cup_id[0]+"]").val() == 'undefined'){
                            var data = "Cup - " + $("p[data-id="+value+"]").parents("li.gs-w").find("span.box-no").text();
                        }
                        else{
                            var data = "Cup - " + $("a[data-id="+value+"]").parents("li.gs-w").find("span.box-no").text();
                        }
                        sel.append($("<option>").attr('value',value).text(data));
                    });
                }
                else{
                    $.msgBox({
                        title:"CUP STATUS",
                        content:"No Such Part Exists Within the Kit"
                    });
                }
            }
        }
        else if(typeof $('#kit_type').val() != 'undefined' && $('#kit_type').val() == "binder"){
            if (cup_id.length == 1) {
                $(".cup_list").html("");
                $("td#"+cup_id+" input").focus();
            }
            else{
                $(".cup_list").html("");
                if(cup_id.length != 0) {
                    $.msgBox({
                        title:"CUP STATUS",
                        content:"You have More than One Cup with part No. "+ $("#part_number_search").val()+". select from the List of Cups to Fill.",
                        type:"info"
                    });
                    var sel = $("<select class= \"input-medium\" onchange = \"cup_record(this.value);\">").appendTo('.cup_list');
                    sel.append($("<option>").attr('value',"").text("Select A Cup"));
                    $.each( cup_id, function( index, value ){
                        var data = "Cup - " + $("td#"+value).parents("tr").find("td input.kit_tray").val();
                        sel.append($("<option>").attr('value',value).text(data));
                    });
                }
                else{
                    $.msgBox({
                        title:"CUP STATUS",
                        content:"No Such Part Exists Within the Kit"
                    });
                }
            }

        }

        else{
            if (cup_id.length == 1) {
                $(".cup_list").html("");
                $("p[data-id="+cup_id[0]+"]").trigger("click");
            }
            else{
                $(".cup_list").html("");
                if(cup_id.length != 0) {
                    $.msgBox({
                        title:"CUP STATUS",
                        content:"You have More than One Cup with part No. "+ $("#part_number_search").val()+". select from the List of Cups to Fill.",
                        type:"info"
                    });
                    var sel = $("<select class= \"form-control\" onchange = \"cup_record(this.value);\">").appendTo('.cup_list');
                    sel.append($("<option>").attr('value',"").text("Select A Cup"));
                    $.each( cup_id, function( index, value ){
                        var data = "Cup - " + $("p[data-id="+value+"]").parents("div.caption").find(".cup_number_label").text();
                        sel.append($("<option>").attr('value',value).text(data));
                    });
                }
                else{
                    $.msgBox({
                        title:"CUP STATUS",
                        content:"No Such Part Exists Within the Kit"
                    });
                }
            }
        }
        evt.preventDefault();
    });

    $("#old_part_no,#new_part_no").on("click",function(e){
        var part_status = $(this).attr("id");
        if (part_status == "old_part_no"){
            var part_num = $("#old_part_number").val();
        }
        else{
            var part_num = $("#new_part_number").val();
        }
        if (part_num == "" || part_num == undefined){
            alert("Enter a Part Number.");
            return false
        }
        else{
            $.ajax({
                type: "POST",
                onLoading: show_spinner(),
                url: '/kitting/parts/search_part',
                data: {"part_number" : part_num,"part_status": part_status },
                success: function(){
                    hide_spinner();
                },
                error:function(){
                    hide_spinner();
                    alert("Error Occured While Searching part");
                },
                dataType: "script"
            });
        }
    });

    $("#new_uom").change(function(event){
        $("#replace_part_button").val("Please Wait..");
        $("#replace_part_button").attr("disabled",true);
        $.ajax({
            beforeSend: function(){
                show_spinner();
            },
            url: "/kitting/kits/uom_look_up",
            type: 'GET',
            data: {part : $("#new_part_number").val().toUpperCase(), uom : $('#new_uom :selected').val()},
            success: function(data) {
                hide_spinner();
                if(data.errMsg == null || data.errMsg == ""){
                    $("#replace_part_button").val("Replace");
                    $("#replace_part_button").attr("disabled",false);
                }
                else {
                    $.msgBox({
                        title:"Part Status",
                        content: data.errMsg
                    });
                    $("#replace_part_button").val("Select different UOM or Refresh.");
                    $("#replace_part_button").attr("disabled",true);
                    return false;
                }
            },
            error: function(jqXHR, textStatus) {
                hide_spinner();
                alert("Error While Fecthing UOM Info.");
            }
        });
    });

    $(".user_lang").click(function(e){
        show_spinner();
        $.get("/user_sessions/change_user_lang?lang="+$(this).attr("id")+"&controller_name="+window.location.pathname.split("/")[1],function(data,status) {
            if ($("#web_order_type").val() == undefined){
                window.location= "/"+data.controller
            }
            else {
                var order_type = $("#web_order_type").val();
                if (order_type == "Sikorsky"){
                    window.location= "/web_order_request?web_order_type=Sikorsky"
                }
                else {
                    window.location= "/web_order_request"
                }
            }
        });
    });

    $(".modal").on('hidden', function () {
        if (!$(this).hasClass('upload_img')) {
            $(this).parent().each (function() { if(this.tagName == "FORM") {this.reset();} });
        }
    });
    if (typeof Dropzone != "undefined"){
        var acceptedFileTypes = ".doc, .docx, .xls, .xlsx";
        Dropzone.options.dropzone = {
            acceptedFiles: acceptedFileTypes,
            init: function() {
                var element = document.getElementById("upload_misc_report");
                element.parentNode.removeChild(element);
                this.on("success", function(file,responseText) {
                    // Create the remove button
                    var removeButton =  Dropzone.createElement("<button class=\"btn btn-danger btn-sm\" val="+ responseText.report.id +">Remove file</button>");
                    // Capture the Dropzone instance as closure.
                    var _this = this;
                    // Listen to the click event
                    removeButton.addEventListener("click", function(e) {
                        // Make sure the button click doesn't submit the form:
                        e.preventDefault();
                        e.stopPropagation();
                        $.ajax({
                            url: "/reports/"+ $(this).attr("val"),
                            type: 'DELETE',
                            dataType: "script",
                            success: function(result) {
                                _this.removeFile(file);
                            },
                            error: function (result){
                                alert("Unable to Remove File , Server cannot process your request.")
                            }
                        });
                    });

                    // Add the button to the file preview element.
                    file.previewElement.appendChild(removeButton);
                });
                this.on("error", function(file) {
                    var removeButton =  Dropzone.createElement("<button class=\"btn btn-danger btn-sm\">Remove file</button>");
                    var _this = this;
                    removeButton.addEventListener("click", function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        _this.removeFile(file);
                    });
                    file.previewElement.appendChild(removeButton);
                });
            }
        };
    }

    $.fn.add_part_popup = function(){
        var cup_id = "";
        var cup_number ='';
        if($(this).attr('class') == 'btn btn-default popup configurable-btn')
        {
            cup_id = $(this).parent('span').parent('div').parent('li').attr('id');
            cup_number = $(this).parent().parent().parent().children('span.box-no').text();
        }
        else
        {
            if ($(this).parent('p').prev('ul').attr('data-id')){
                cup_id = $(this).parent('p').prev('ul').attr('data-id');
                cup_number = $(this).parent().parent().find('h5').find(".cup_number_label").text();
                cup_number = cup_number.replace ( /[^\d.]/g, '' );
            }
        }

        //$(".popup_pages").removeClass("active");
        $.get('/kitting/cups/'+cup_id+'/build', function(data) {
            $('#part_select_modal').modal({"backdrop": "static"});
            $('#cup_id').val(cup_id);
            $("#cup_number").val(cup_number);
            $('#cup_number_info').text(cup_number);
        });
    };

    jQuery.fn.load_compartment = function() {
        if(typeof $('#compartment_layout').val() != 'undefined') {
            var cup_len = 0;
            var cup_btn = "";
            var multiple_part ="";

            $.each($('.thumbnails').find('.thumbnail'), function() {
                cup_len = $(this).find("ul.cup_parts").find("li").length;
                cup_btn = $(this).find("p.add_button a");
                multiple_part = $("#multiple_part").val();

                if (cup_len == 0 )
                {
                    cup_btn.html("<span class = 'glyphicon glyphicon-plus-sign'></span>");
                }
                else
                {
                    if($(this).children().is("li:contains('Water-Level')") || $(this).children().is("li:contains('WL')"))
                    {
                        cup_btn.html("<span class = 'glyphicon glyphicon-edit'></span>");
                    }
                    else
                    {
                        if(multiple_part == "true" && $(this).parent().parent().hasClass('non-contract-cup') != true )
                        {

                            cup_btn.html("<span class='glyphicon glyphicon-edit'></span>");
                        }
                        else
                        {

                            cup_btn.html("<span class = 'glyphicon glyphicon-edit'></span>");
                        }
                    }
                }

            });

        }

        if(typeof $('#kit_type').val() != 'undefined' && $('#kit_type').val() == "configurable") {
            var multiple_part = $("#multiple_part").val();
            $("ul#configurable_cups .block_area").each(function () {
                var elem = $(this);
                var $editPart = elem.parent().find("#edit-part");
                var $editSign = elem.parent().find("#edit-sign");
                var $plusSign = elem.parent().find("#plus-sign");

                if (elem.children().length == 0) {
                    $editPart.removeClass();
                    $editSign.removeClass();
                }

                else {
                    $plusSign.removeClass("glyphicon glyphicon-plus-sign");
                    $plusSign.addClass("glyphicon glyphicon-edit");
                }
            });
        }
    };
});

function change_account(customer_number){

    $.ajax({
        url: "/switch_account",
        type: 'GET',
        data: {"customer_number": customer_number,"controller_name": window.location.pathname.split("/")[1]},
        onLoading: show_spinner(),
        success: function(data) {
            hide_spinner();
            if (data.controller == "kitting")
            {
                window.location= "/"+data.controller+"/kits"
            }
            else if ($("#web_order_type").val() != undefined)
            {
                var order_type = $("#web_order_type").val();
                if (order_type == "Sikorsky"){
                    window.location= "/web_order_request?web_order_type=Sikorsky"
                }
                else {
                    window.location= "/web_order_request"
                }
            }
            else
            {
                window.location= "/"+data.controller
            }
        },
        error: function(jqXHR, textStatus) {
            hide_spinner();
            alert( "Unsuccessful Request: " + textStatus );
        }
    });
};

function load_table_sorter(){
    $('.tablesorter').tablesorter({
        theme : "bootstrap",
        widthFixed: true,
        headerTemplate : '{content} {icon}', // new in v2.7. Needed to add the bootstrap icon!
        widgets : [ "filter", "zebra" ],
        widgetOptions : {
            zebra : ["even", "odd"],
            filter_reset : ".reset"
        }
    });
};
/*jQuery(document).ready completed */
// Show hide spinner
function show_spinner() {
    jQuery(".spinner").removeClass("disp-block");
    jQuery(".spin_overlay").removeClass("disp-block");
};

function hide_spinner() {
    jQuery(".spin_overlay").addClass("disp-block");
    jQuery(".spinner").addClass("disp-block");
};
/*jQuery(document).ready completed */
// start stop configuring cup layout
function start_configuring() {
    jQuery(".start_configuring").removeClass("disp-config");
    jQuery(".stop_configuring").removeClass("disp-config");
    jQuery(".configuring").removeClass("disp-config");
};

function stop_configuring() {
    jQuery(".start_configuring").addClass("disp-config");
    jQuery(".stop_configuring").addClass("disp-config");
    jQuery(".configuring").addClass("disp-config");
};

function checkfile(sender,type) {
    var validExts = new Array(type);
    var fileExt = sender.value;
    fileExt = fileExt.substring(fileExt.lastIndexOf('.')).toLowerCase();
    if (type == '.xlsx' ) {
        validExts.push('.xls');
    }
    if (validExts.indexOf(fileExt) < 0) {
        $("#new_kit_bom_bulk_operation").trigger('reset');
        $.msgBox({
            title:"Invalid File Format",
            content:"Invalid file selected, valid files should be of (" + validExts.toString() + ") type."
        });
        return false;
    }
    else return true;
}

function upload_status(status){
    if(status == "COMPLETED" || status == "FAILED" ){
        return true;
    }
    else {
        $.msgBox({
            title:"FILE STATUS",
            content:"THIS FILE IS BEING "+ status +" , CLICK TO DOWNLOAD ONCE IT IS COMPLETED.",
            type:"info"
        });
        return false;
    }
}
function cup_record(id){
    if(typeof $('#kit_type').val() != 'undefined' && $('#kit_type').val() == "configurable"){
        if (typeof $("a[data-id="+id+"]").val() == 'undefined'){
            $("p[data-id="+id+"]").trigger("click");
        }
        else{
            $("a[data-id="+id+"]").trigger("click");
        }
    }
    if(typeof $('#kit_type').val() != 'undefined' && $('#kit_type').val() == "binder"){
        $("td#"+id+" input").focus();
    }
    else{
        $("p[data-id="+id+"]").trigger("click");
    }
}