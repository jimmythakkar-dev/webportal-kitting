function customKitPN(key,value){
    if( key > 0){
        show_spinner();
        $.ajax({
            url: "/custom_kits/get_kit_part_numbers?aircraft_id",
            type: 'GET',
            data: {
                "aircraft_id": value
            },
            success: function (data) {
                hide_spinner();
            },
            error: function (data) {
                hide_spinner();
                alert("Unsuccessful Request");
            }

        });
    }
}