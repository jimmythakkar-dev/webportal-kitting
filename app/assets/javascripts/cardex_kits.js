function select_cup(all_cups ,cup) {
    all_cups.removeClass("selected_cup");
    cup.addClass("selected_cup");
    all_cups.css("background-color", "#DDDDDD");
    cup.css("background-color", "#ffffff");
    cup.addClass("selected_cup");

    $("#kit_media_type").attr("disabled", true);
    $("#change_mmt").css("display", "inline");
    $(".print").css("display", "inline");
}
//=================================================================

function get_row_col_values(li){
    var lrow = li.attr("data-row");
    var lcol = li.attr("data-col");
    var lx = li.attr("data-sizex");
    var ly = li.attr("data-sizey");
    return lrow + "," + lcol + "," + lx + "," + ly
}
//=================================================================


function get_fill_cup( part_list){
    var partList = [];
    var cupList = [];
    var gridster_li;

    $.each(part_list, function(i, value){
        partList.push($(this).text());
    });
    if($("#kit_type").val() == "non-configurable"){
        gridster_li = $(".thumbnail .cup_parts")
    }
    if($("#kit_media_type").val() == "Small Removable Cup TB" )
    {
        $.each($("#small_yellow_kit li"), function(i, li){
            if($(this).attr("data-row") > 6){
                $(this).remove();
            }
        });
        gridster_li = $("#small_yellow_kit li")
    }
    else if($("#kit_media_type").val() == "Large Removable Cup TB" )
    {
        $.each($(".kit_container li"), function(i, li){
            if($(this).attr("data-row") > 4){
                $(this).remove();
            }
        });
        gridster_li =$(".kit_container li")
    }

    $.each(gridster_li, function(i, value){
        if(partList[0] && gridster_li[i]){
            $(this).html($(this).html() + "<p>"+ partList[0]);
            partList.splice(0,1);
            $($(".part_list li")[0]).remove();
        }
    });
}

function get_twenty_four_rtb_tl_layout(){
    var twenty_four_rtb_tackle_box;
    twenty_four_rtb_tackle_box = $("#twenty_four_rtb_tackle_box > ul").gridster({
        namespace: '#twenty_four_rtb_tackle_box',
        widget_margins: [5, 5],
        widget_base_dimensions: [110, 100],
        resize: {
            enabled: false
        }
    }).data('gridster').disable();
}

function resetboxno() {
    var count = 1;
    $(".gs-w").each(function(){
        $(this).find(".box-no").text(count);
        count++;
    });
}

//=================================================================
//  on click print generate data to store in DB
//=================================================================
function get_row_col_valuesfor_non_config(ul){
    var li = ul.find("li");
    var lrow = li.attr("data-row");
    var lcol = li.attr("data-col");
    return lrow + "," + lcol
}
function resizeDiv() {
    vpw = $(window).width();
    vph = $(window).height() - 248;
    $(".part_list").css({"min-height": $(window).height() + "px"});
    $(".part_list ul").css({"height": vph + "px"});
}
function show_spinner() {
    jQuery(".spinner").removeClass("disp-block");
    jQuery(".spin_overlay").removeClass("disp-block");
};

function hide_spinner() {
    jQuery(".spin_overlay").addClass("disp-block");
    jQuery(".spinner").addClass("disp-block");
};
//=================================================================
//  On press E empty parts from cup
//=================================================================

$(document).keyup(function(e) {
    if($("#kit_type").val() == "non-configurable"){
        var lparts2 = "";

        if (e.keyCode == 69) {
            if ($(".selected_cup").length == 1){
                $.each($(".selected_cup").find("p"), function(i){
                    lparts2 +=  "<li>" + $(this).text() + "</li>";
                    $(this).remove();
                });
                $(".part_list ul").prepend(lparts2);
            }
        }
    }
});

$(document).ready(function(){
    var parts_array = [];
    //$.each($(".gs-w").find("p"), function(i){
    //    if($(this).length > 0){
    //        parts_array.push($(this).text());
    //        $('.part_list li:contains('+$(this).text()+')').remove();
    //    }
    //});
    //$.each($("ul.cup_parts").find("p"), function(i){
    //    if($(this).length > 0){
    //        parts_array.push($(this).text());
    //        $('.part_list li:contains('+$(this).text()+')').remove();
    //    }
    //});

    // Set PartList Height
    resizeDiv();
    window.onresize = function(event) {
        resizeDiv();
    };

    //=================================================================
    // part detail tooltip
    //=================================================================
    $(".part_tooltip").on( "mouseover", function(e) {
        $(".part_tooltip").css("display","none");
    });
    $(".part_list").on( "mouseover","li", function(e) {
        var part_number = $(this).attr("val");
        var x = e.clientX,
            y = e.clientY;
        $.get('/kitting/cardex_kits/build_part',{part_number: part_number}, function(data) {
            if(data != "$('.part_tooltip').html('');"){
                $(".part_tooltip").css({"display":"block", "top":(y) + 'px', "left":(260) + 'px' });
            }
            else{
                $(".part_tooltip").css("display","none");
            }

        })
    }).on( "mouseout","li", function(e) {
        $(".part_tooltip").css("display","none");
    });
    //=================================================================

    //=================================================================
    //  Fill All Cup from list to Kit
    //=================================================================
    $(".fill_all_cups").on("click",function(){
        get_fill_cup($(".part_list li"));
    });
    //=================================================================


    //=================================================================
    //  Fill Selected part to Cup from part list to Kit
    //=================================================================
    $(".part_list").on("click","li",function(){
        var li = "";
        if($(".gridster ul").length > 0){
            li = $(".gridster ul").find("li.selected_cup");
        }
        else{
            li = $(".thumbnail").find("ul.selected_cup");
        }

        if (li.length == 0){
            alert("Please Select Cup");
        }
        else{

            li.html(li.html() +"<p>" + $(this).html()) ;
            $(this).remove()
        }

    });
    //=================================================================


    //=================================================================
    //  Reset Media Type
    //=================================================================
    $("#change_mmt").click(function(){
        $("#searchCardexKit").click();
    });
    //=================================================================

    $(".container").on("click",".print",function(){
        if($(".part_list li").length > 0){
            alert("Please fill the remaining parts");
            return false
        }else
        {
            if ($.trim($("#mmt_kit").val()) != ""){
                $(".save_cardex_layout").trigger("click");
            }else{
                var row_values,row_values1,row_values2;
                var lno,lno1,lno2;
                var lgr, lgr1,lgr2;
                var livalues,livalues1,livalues2;
                var html_final= {},html_final1= {},html_final2 = {};

                if($("#kit_type").val() == "non-configurable"){
                    $.each($(".thumbnail .cup_parts"), function(i){
                        var lparts = "";
                        row_values = get_row_col_valuesfor_non_config($(this));
                        lno = $(this).find(".box-no").text();
                        //lgr = 1;
                        $.each($(this).find("p"), function(i){
                            if($(this).length > 0){
                                if(i > 0){
                                    lparts +=  "#" + $(this).text();
                                }else{
                                    lparts = $(this).text();
                                }
                            }
                        });
                        livalues = row_values + "," + lparts;
                        html_final[lno] = livalues;

                    });

                }else if($("#kit_media_type").val() == "Small Removable Cup TB"){
                    $.each($("#small_yellow_kit li"), function(i){
                        var lparts = "";
                        row_values = get_row_col_values($(this));
                        lno = $(this).find(".box-no").text();
                        lgr = 1;
                        $.each($(this).find("p"), function(i){
                            if(i > 0){
                                lparts +=  "#" + $(this).text();
                            }else{
                                lparts = $(this).text();
                            }
                        });
                        livalues = row_values + "," + lgr + "," + lparts;
                        html_final[lno] = livalues;
                    });
                }else if($("#kit_media_type").val() == "Large Removable Cup TB"){

                    $.each($(".gridster_part_3_0 li"), function(i){
                        var lparts = "";
                        row_values = get_row_col_values($(this));
                        lno = $(this).find(".box-no").text();
                        lgr = 1;
                        $.each($(this).find("p"), function(i){
                            if(i > 0){
                                lparts +=  "#" + $(this).text();
                            }else{
                                lparts = $(this).text();
                            }
                        });
                        livalues = row_values + "," + lgr + "," + lparts;
                        html_final[lno] = livalues;
                    });
                    $.each($(".gridster_part_3_1 li"), function(i){
                        var lparts1 = "";
                        row_values1 = get_row_col_values($(this));
                        lno1 = $(this).find(".box-no").text();
                        lgr1 = 2;
                        $.each($(this).find("p"), function(i){
                            if(i > 0){
                                lparts1 +=  "#" + $(this).text();
                            }else{
                                lparts1 = $(this).text();
                            }
                        });
                        livalues1 = row_values1 + "," + lgr1 + "," + lparts1;
                        html_final1[lno1] = livalues1;
                    });
                    $.each($(".gridster_part_3_2 li"), function(i){
                        var lparts2 = "";
                        row_values2 = get_row_col_values($(this));
                        lno2 = $(this).find(".box-no").text();
                        lgr2 = 3;
                        $.each($(this).find("p"), function(i){
                            if(i > 0){
                                lparts2 +=  "#" + $(this).text();
                            }else{
                                lparts2 = $(this).text();
                            }
                        });
                        livalues2 = row_values2 + "," + lgr2 + "," + lparts2;
                        html_final2[lno2] = livalues2;
                    });

                }

                $("#kit_html_layout").val(JSON.stringify(html_final));
                $("#kit_html_layout1").val(JSON.stringify(html_final1));
                $("#kit_html_layout2").val(JSON.stringify(html_final2));
                $("#print_kit_media_type").val($("#kit_media_type").val())
            }
        }
    });

    $("body").on("click",".reset_cardex_kit_layout",function(){
        var confirm_return = confirm("Reset kit layout?");
        if(confirm_return == true){
            return
        }else{
            return false
        }
    });

    $("ul").on("click","li.gs-w",function(){
        select_cup($(".gridster li"), $(this));
    });
    $(".container").on("click","ul.cup_parts", function(){
        select_cup($(".thumbnail .cup_parts"), $(this));
    });

    $("body").on("click",".edit-media-type a",function(e){
        $('.add-media-type-li').css('display','block');
        $('#add_media_type_submit').css('display','block');
        $(this).parent().css('display','none');
    });
    $("body").on("click",".hide-add-media-type-li",function(e){
        $('.add-media-type-li').css('display','none');
        $('#add_media_type_submit').css('display','none');
        $('.edit-media-type').css('display','block');
    });

    $("body").on("click",".add-media-type, li a.remove_media_type",function(event){
        var kit_media_type_id = $("#add_design_kit_media_type_id").val();
        if ($(this).hasClass("add-media-type")){
            var action = "Are you sure to create a Sub Kit?"
            var type = "add"
            var box_number = !$(this).hasClass("box_1");
        }
        else{
            var action = "Are you sure to remove Sub Kit?"
            var type = "remove"
            var box_number = false;
        }
        if (box_number){
            $(".save_cardex_layout").trigger("click");
        }
        var action_btn = confirm(action);
        if( action_btn == true) {
            $.ajax({
                url: "/kitting/cardex_kits/" + $(this).attr('id') +"/add_remove_mmt_kit",
                type: 'POST',
                data: { "kit_media_type": kit_media_type_id, "type": type },
                aysnc: false,
                beforeSend: function() {
                    if ($(".part_list ul li").length > 0 ){
                        return true
                    }
                    else{
                        if (type == "remove"){
                            return true
                        }else{
                            hide_spinner();
                            $(".hide-add-media-type-li").trigger("click");
                            alert("There are no more part to fill.");
                            return false;
                        }
                    }
                },
                onLoading: show_spinner(),
                success: function (data) {},
                error: function (jqXHR, textStatus) {
                    hide_spinner();
                    alert("Please Try Again");
                }
            });
        }else{
            return false;
        }
    });

    // Method Call when A Lay out Is Saved in KMT

    $(".container").on("click","#save_non_config_kit_layout", function(){
        var kit_number = $("#kit_number").val();
        var mmt_kit = $.trim($("#mmt_kit").val());
        var cardex_kit_id = $("#cardex_kit_id").val();
        var row_values,row_values1,row_values2;
        var lno,lno1,lno2;
        var lgr, lgr1,lgr2;
        var livalues,livalues1,livalues2;
        var html_final= {},html_final1= {},html_final2 = {};



        $.each($(".thumbnail .cup_parts"), function(i){
            var lparts = "";
            row_values = get_row_col_valuesfor_non_config($(this));
            lno = $(this).find(".box-no").text();
            //lgr = 1;
            $.each($(this).find("p"), function(i){
                if($(this).length > 0){
                    if(i > 0){
                        lparts +=  "#" + $(this).text();
                    }else{
                        lparts = $(this).text();
                    }
                }
            });
            livalues = row_values + "," + lparts;
            html_final[lno] = livalues;

        });

        $("#kit_html_layout").val(JSON.stringify(html_final));
        $("#kit_html_layout1").val(JSON.stringify(html_final1));
        $("#kit_html_layout2").val(JSON.stringify(html_final2));

        var serialize_data = $("#kit_html_layout").val();
        var serialize_data1 = $("#kit_html_layout1").val();
        var serialize_data2 = $("#kit_html_layout2").val();
        var update_cup_id = new Array();

        $.ajax({
            url: '/kitting/cardex_kits/save_layout',
            data: {"kit_number" : kit_number, "kit_html_layout": serialize_data, "kit_html_layout1": serialize_data1, "kit_html_layout2": serialize_data2 ,"cardex_kit": cardex_kit_id, "mmt_kit" : mmt_kit },
            type: "PUT",
            aysnc: false,
            //onLoading: start_configuring(),
            success: function(data){
                $("#save_template_alert").css("visibility","visible");
                setTimeout(function() { $("#save_template_alert").css("visibility","hidden"); }, 4000);
            },
            error: function(data) {
                //stop_configuring();
                alert( "Unable to update");
            }
        });
    });

    $(".container").on("click","#save_cardex_kit_layout",function(){
        var kit_number = $("#kit_number").val();
        var mmt_kit = $.trim($("#mmt_kit").val());
        var cardex_kit_id = $("#cardex_kit_id").val();
        var row_values,row_values1,row_values2;
        var lno,lno1,lno2;
        var lgr, lgr1,lgr2;
        var livalues,livalues1,livalues2;
        var html_final= {},html_final1= {},html_final2 = {};

        if($(".gridster_part_3_0 ").length > 0){
            $.each($(".gridster_part_3_0 li"), function(i){
                var lparts = "";
                row_values = get_row_col_values($(this));
                lno = $(this).find(".box-no").text();
                lgr = 1;
                $.each($(this).find("p"), function(i){
                    if(i > 0){
                        lparts +=  "#" + $(this).text();
                    }else{
                        lparts = $(this).text();
                    }
                });
                livalues = row_values + "," + lgr + "," + lparts;
                html_final[lno] = livalues;
            });
            $.each($(".gridster_part_3_1 li"), function(i){
                var lparts1 = "";
                row_values1 = get_row_col_values($(this));
                lno1 = $(this).find(".box-no").text();
                lgr1 = 2;
                $.each($(this).find("p"), function(i){
                    if(i > 0){
                        lparts1 +=  "#" + $(this).text();
                    }else{
                        lparts1 = $(this).text();
                    }
                });
                livalues1 = row_values1 + "," + lgr1 + "," + lparts1;
                html_final1[lno1] = livalues1;
            });
            $.each($(".gridster_part_3_2 li"), function(i){
                var lparts2 = "";
                row_values2 = get_row_col_values($(this));
                lno2 = $(this).find(".box-no").text();
                lgr2 = 3;
                $.each($(this).find("p"), function(i){
                    if(i > 0){
                        lparts2 +=  "#" + $(this).text();
                    }else{
                        lparts2 = $(this).text();
                    }
                });
                livalues2 = row_values2 + "," + lgr2 + "," + lparts2;
                html_final2[lno2] = livalues2;
            });
        }
        else if($("#small_yellow_kit").length > 0){
            var $wrapper = $('.small-template');
            $wrapper.find('.gs-w').sort(function (a, b) {
                return +a.getAttribute('data-col') - +b.getAttribute('data-col');
            }).appendTo( $wrapper );
            $wrapper.find('.gs-w').sort(function (a, b) {
                return +a.getAttribute('data-row') - +b.getAttribute('data-row');
            }).appendTo( $wrapper );

            $.each($("#small_yellow_kit li"), function(i){
                var lparts = "";
                row_values = get_row_col_values($(this));
                lno = i+1;
                lgr = 1;
                $.each($(this).find("p"), function(i){
                    if(i > 0){
                        lparts +=  "#" + $(this).text();
                    }else{
                        lparts = $(this).text();
                    }
                });
                livalues = row_values + "," + lgr + "," + lparts;
                html_final[lno] = livalues;
            });
        }

        $("#kit_html_layout").val(JSON.stringify(html_final));
        $("#kit_html_layout1").val(JSON.stringify(html_final1));
        $("#kit_html_layout2").val(JSON.stringify(html_final2));

        var serialize_data = $("#kit_html_layout").val();
        var serialize_data1 = $("#kit_html_layout1").val();
        var serialize_data2 = $("#kit_html_layout2").val();

        $.ajax({
            url: '/kitting/cardex_kits/save_layout',
            data: {"kit_number" : kit_number, "kit_html_layout": serialize_data, "kit_html_layout1": serialize_data1, "kit_html_layout2": serialize_data2 ,"cardex_kit": cardex_kit_id, "mmt_kit" : mmt_kit },
            type: "PUT",
            //onLoading: start_configuring(),
            success: function(data){
                $("#save_template_alert").css("visibility","visible");
                setTimeout(function() { $("#save_template_alert").css("visibility","hidden"); }, 4000);
            },
            error: function(data) {
                window.location.reload()
            }
        });
    });

    $("body").on("click",".edit-media-type a",function(e){
        $('.add-media-type-li').css('display','block');
        $('#add_media_type_submit').css('display','block');
        $(this).parent().css('display','none');
    });
    $("body").on("click",".hide-add-media-type-li",function(e){
        $('.add-media-type-li').css('display','none');
        $('#add_media_type_submit').css('display','none');
        $('.edit-media-type').css('display','block');
    });
});