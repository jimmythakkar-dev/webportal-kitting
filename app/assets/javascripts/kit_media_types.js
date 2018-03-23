$(document).ready(function() {
    $("#kit_media_type_compartment").keyup(function() {
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

//    >>>>>>>>>>>>>>>>>>>>>>>>>>  START JS CODE >>>>>>>>>>>>>>>>>>>>>>>

    $('.kit_media_type').click(function () {
        kit_media_type = $("input[type='radio'][name='kit_media_type[kit_type]']:checked").val();
        if (kit_media_type == "binder") {
            $(".kit_media_type_rows").hide();
            $(".kit_media_type_add_row").hide();
            $("#compartment_label").css('display', 'none');
            $("#kit_media_type_compartment").val(1000);
            $("#kit_media_type_compartment").css('display', 'none');
            $(".kmt_name").css("display","block")
            $("#kit_media_type_name").attr("required",true);
            $("#kit_media_type_name").val("");
            $("#kit_media_type_name").attr("disabled",false);
            $(".configurable_kmt").css("display","none");
            $("#configurable_kmt").attr("required",false);
        }
        else if (kit_media_type == "configurable") {
            $(".kit_media_type_rows").hide();
            $(".kit_media_type_add_row").hide();
            $("#compartment_label").css('display', 'block');
            $("#kit_media_type_compartment").css('display', 'none');
            $("#kit_media_type_compartment").val('');
            $(".configurable_kmt").css("display","block");
            $(".compartment_label").css("display","none");
            $(".kmt_name").css("display","none");
            $("#kit_media_type_name").attr("required",false);
            $("#kit_media_type_compartment").attr("required",false);
            $("#configurable_kmt").attr("required",true);
        }
        else if (kit_media_type == "multi-media-type") {
            $(".kit_media_type_rows").hide();
            $(".kit_media_type_add_row").hide();
            $("#compartment_label").css('display', 'none');
            $("#kit_media_type_compartment").css('display', 'none');
            $("#kit_media_type_compartment").val('');
            $(".configurable_kmt").css("display","none");
            $(".compartment_label").css("display","none");
            $(".kmt_name").css("display","block");
//            $("#kit_media_type_name").attr("required",false);
            $("#kit_media_type_compartment").attr("required",false);
            $("#configurable_kmt").attr("required",false);

            $("#kit_media_type_name").attr("disabled",true);
            $("#kit_media_type_name").val("Multiple Media Type");
        }
        else {
            $(".kit_media_type_rows").show();
            $(".kit_media_type_add_row").show();
            $("#compartment_label").css('display', 'block');
            $("#compartment_label").text("Number of Compartments");
            $("#kit_media_type_compartment").css('display', 'block');
            $("#kit_media_type_compartment").val('');
            $(".compartment_label").css("display","block");
            $(".kmt_name").css("display","block")
            $("#kit_media_type_name").attr("required",true);
            $("#kit_media_type_name").val('');
            $("#kit_media_type_name").attr("disabled",false);
            $(".configurable_kmt").css("display","none");
            $("#kit_media_type_compartment").attr("required",true);
            $("#configurable_kmt").attr("required",false);
        }
    });

    $('.media_type').on('click',function(){
        kit_media_type = $("input[type='radio'][name='kit_media_type[kit_type]']:checked").val();
        number_of_compartments = $("#kit_media_type_compartment").val();
        if (kit_media_type == "binder"){
            if (number_of_compartments > 1000){
                alert("Binder Limit of 1000 in compartments.");
                return false;
            }
        }
        number_of_rows = parseInt($('.compartment-layout').last().attr('name').match(/\d+/)[0])
        if ((kit_media_type != "binder" || kit_media_type != "configurable") && number_of_compartments != "" && number_of_rows > number_of_compartments){
            alert("Please enter Number of cups in Rows greater than Number of Compartments");
            return false;
        }
        var sum = 0;
        for(i=0;i<number_of_rows;i++)
        {
            row_count = i+1;
            value = parseInt($("input[name='kit_media_type[compartment_layout]["+row_count+"]']").val());
            sum += !isNaN(value) ? value : 0;
        }

        if ((kit_media_type == "non-configurable")&& (number_of_compartments == "" || sum != number_of_compartments)){
            alert("Please enter sum of values inside Number of cups in Rows as same as Number of Compartments");
            return false;
        }
        return true;
    });

//    >>>>>>>>>>>>>>>>>>>>>>>>>>  END JS CODE >>>>>>>>>>>>>>>>>>>>>>>

    $('.kit-media-type-add-row').click(function () {
        var new_row_number = parseInt($('.compartment-layout').last().attr('name').match(/\d+/)[0]) + 1;
            $('.kit_media_type_rows').append("<div class='control-group'><label class='control-label'>Number of cups in Row"+new_row_number+"</label><div class='controls inline'><input type='text' name='kit_media_type[compartment_layout]["+new_row_number+"]' class='compartment-layout form-control' id='kit_media_type[compartment_layout]["+new_row_number+"]'/><img class='ImgDelete' src='/assets/delete.gif'/></div></div>");
    });

    $('.kit_media_type_rows').delegate('img.ImgDelete', 'click', function(e) {
        $(this).parent().parent().remove();
    });
    $('#kit_media_type_kit_type_multi-media-type').click(function(e) {
        if ($('#kit_media_type_kit_type_multi-media-type').is(':checked')) {
            show_spinner();
            $.ajax({
                url: '/kitting/kit_media_types/search_duplicate',
                data: {"media_type_name" : $("#kit_media_type_name").val() },
                type: "POST",
                dataType: 'json',
                success: function(data){
                    if(data.status){
                        hide_spinner();
                    }
                    else if(data.authorized) {
                        hide_spinner();
                        $.msgBox({
                            title:"KIT MEDIA TYPE EXISTS",
                            content:"Kit Media Type "+data.kmt+" already exists.",
                            type:"info"
                        });
                    }
                    else{
                        hide_spinner();
                        $.msgBox({
                            title:"AUTHENTICATION FAILED",
                            content:"YOU ARE NOT AUTHORIZED TO CREATE SELECTED MEDIA TYPE",
                            type:"warn"
                        });
                    }
                },
                error: function(data) {
                    hide_spinner();
                    $.msgBox({
                        title:"Error Occured",
                        content:"Error Occured While Retreiving Kit Media Type List.",
                        type:"info"
                    });
                }
            });
        }
    });
    $("#configurable_kmt").change(function(e){
        if ($(this).val()) {
            show_spinner();
            $.ajax({
                url: '/kitting/kit_media_types/search_duplicate',
                data: {"media_type_id" : $(this).val() },
                type: "POST",
                dataType: 'json',
                success: function(data){
                    if(data.status){
                        hide_spinner();
                    }
                    else if(data.authorized) {
                        hide_spinner();
                        $.msgBox({
                            title:"KIT MEDIA TYPE EXISTS",
                            content:"Kit Media Type "+data.kmt+" already exists.",
                            type:"info"
                        });
                    }
                    else{
                        hide_spinner();
                        $.msgBox({
                            title:"AUTHENTICATION FAILED",
                            content:"YOU ARE NOT AUTHORIZED TO CREATE SELECTED MEDIA TYPE",
                            type:"warn"
                        });
                    }
                },
                error: function(data) {
                    hide_spinner();
                    $.msgBox({
                        title:"Error Occured",
                        content:"Error Occured While Retreiving Kit Media Type List.",
                        type:"info"
                    });
                }
            });
        }
    });


});
$(".media_type").click(function(){
    row_number =  $('.compartment-layout').last().attr('name').match(/\d+/)[0];
    for(i = 1;i <= row_number;i++){
        value = $("input[name='kit_media_type[compartment_layout]["+i+"]']").val();
        if(value != ""  && value !== undefined && !value.match(/^[0-9]+$/)){
            alert("Please enter Number of cups in Rows as integer values");
            return false;
        }
    }
});
$("#display_media_type").on("click",function(e){
    var id= $("#media_type :selected").val();
    if ($("#kit_detail").html().match(/\S/) == null && id =="") {
        $("#media_type").focus().addClass('active');
        $.msgBox({
            title:"Invalid Media Type",
            content:"Invalid Media Type selected, Select a Media type from the List.",
        });
        e.preventDefault();
    }
    else{
        $.ajax({
            url: "/kitting/kit_media_types/"+id,
            onLoading: show_spinner(),
            success: function(data){
                hide_spinner();
                $('#media_modal').modal();
            },
            error: function(data) {
                hide_spinner();
                alert( "Error Fetching Media type Detail.");
            },
            dataType: "script"
        });
    }

});