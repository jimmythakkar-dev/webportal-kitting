$(document).ready(function() {
    $('#update_item_note').focus();
    $('#search_by_building').change(function() {
        var path_name = window.location.pathname;
        $(location).attr('href', path_name+ "?building="+$(this).val());
    });

    $('#search_by_show').change(function() {
        var path_name = window.location.pathname;
        var building = $('#search_by_building option:selected').val();
        $(location).attr('href', path_name + "?open_close="+$(this).val()+ "&building=" +building );
    });

    $('.datepicker').datepicker({
        dateFormat: 'mm/dd/yy',
        //showOn: 'both',
        //buttonImage: window.publicURL+'/assets/calendar.gif',
        //buttonImageOnly: false,
        dayNamesMin: ["S", "M", "T", "W", "T", "F", "S"]
    });

    $('.status').click(function(){
        var status = $(this).attr('id');
        $("#rec_" + status).toggle();
    });
    $(".tr_pop_down").hide();

    $('.btn_submit').click(function(){

        if($('#status option:selected').val() == "Select"){
            alert("Please select Critical or Watch status.");
            $('#status').focus();
            return false;
        }

        if($('#line_responsible option:selected').val() == "Select"){
            alert("Please enter the Line Responsible.");
            $('#line_responsible').focus();
            return false;
        }

        if($('#building option:selected').val() == "Select"){
            alert("Missing Building.");
            $('#building').focus();
            return false;
        }

        if($('#location option:selected').val() == "Select"){
            alert("Missing Location.");
            $('#location').focus();
            return false;
        }

        if($('#program option:selected').val() == "Select"){
            alert("Missing Program.");
            $('#program').focus();
            return false;
        }

        if($('#part_number').val() == ""){
            alert("Missing Part Number.");
            $('#part_number').focus();
            return false;
        }

        if($('#minimum_need_quantity').val() == ""){
            alert("Missing Minimum Need Qty.");
            $('#minimum_need_quantity').focus();
            return false;
        }

        if($('#minimum_need_quantity').val() == ""){
            alert("Missing Minimum Need Qty.");
            $('#minimum_need_quantity').focus();
            return false;
        }

        if($('#update_item_note').val() == "" || $('#update_item_note').val() == " "){
            alert("Please enter the Status Note to continue.");
            $('#update_item_note').focus();
            return false;
        }
        return true;
    });
});

function updatecities(selectedcitygroup){
    var location_list = document.getElementById("location")
    var program_list = document.getElementById("program")

    var locations = new Array()
    locations[0] = ""
    locations[1] = ["Select","B-60", "B-66", "B-75","B-102", "B-220", "B-245","B-248", "B-288", "B-506","B-598", "B-830"]
    locations[2] = ["Select","Install", "Structures", "Final", "St. Clair"]
    locations[3] = ["Select","C-17", "F-15", "Sub Shops", "F-18 C/D Wing", "PAC Center","B-101 Watch"]

    var programs = new Array()
    programs[0] = ""
    programs[1] = ["Select","F-18", "F-15", "F-18 Final","F-15 Final", "Kitting", "SDB", "JDAM","Missiles", "Harpoon", "Phantom Works","Flight Test", "HALE", "UCAV","Simulator"]
    programs[2] = ["Select","F-18", "F-15"]
    programs[3] = ["Select","F-15", "C-17", "F-18"]

    location_list.options.length = 0
    if (selectedcitygroup > 0){
        for (i=0; i < locations[selectedcitygroup].length; i++)
            location_list.options[location_list.options.length] = new Option(locations[selectedcitygroup][i], locations[selectedcitygroup][i])
    }

    program_list.options.length=0
    if (selectedcitygroup>0){
        for (j=0; j < programs[selectedcitygroup].length; j++)
            program_list.options[program_list.options.length] = new Option(programs[selectedcitygroup][j], programs[selectedcitygroup][j])

    }

}

function DoNav(val,history_id) {
    var path_name = window.location.pathname;

    if(val.indexOf('/') != -1)
    {
        val = val.replace("/","@");
    }
    if (history_id == 0)
    {
        document.location.href = path_name + "/" +val+"?history_id="+history_id;
    }
    else
    {
        var pathArray = window.location.pathname.split( '/' );
        var newPathname = "";
        for ( i = 0; i < pathArray.length; i++ ) {
            if (pathArray[i] != ""){
                newPathname += "/";
            }
            if (pathArray[i] == "view_history"){
                pathArray[i] = "?history_id="+history_id;
            }
            newPathname += pathArray[i];

        }
        document.location.href = newPathname;

    }
}
