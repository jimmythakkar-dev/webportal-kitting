$(document).ready(function() {
    $('#part_image_name').change(function(){
        $('.parts_image').css('display', 'block');
        if (this.files && this.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                $('#new_part_image')
                    .attr('src', e.target.result);
            };

            reader.readAsDataURL(this.files[0]);
        }
    });

//    Jquery Method to trim Characters and Symbol from Cup Count
    $("body").on("keyup paste", "#part_medium_cup_count,#part_large_cup_count,#part_small_cup_count", function (e) {
        if(this.value.match(/[^0-9]/g)){
            alert('Only Numeric Value Allowed for Quantity field');
            $(this).val(0);
        }
    });
//    Js Method to Compare Large/Medium & Small Cup Count
    $(".part_cup_image").submit(function(event){

        var part_small_cup_count = parseInt($("#part_small_cup_count").val()) || 0;
        var part_medium_cup_count = parseInt($("#part_medium_cup_count").val()) || 0;
        var part_large_cup_count = parseInt($("#part_large_cup_count").val()) || 0;

        if(part_large_cup_count < part_medium_cup_count && part_medium_cup_count > 0 ){
            alert("Large Cup Count should be Greater than Medium Cup Count");
            event.preventDefault();
        }
        else{
            if(part_medium_cup_count < part_small_cup_count && part_small_cup_count > 0 ) {
                alert("Medium Cup Count should be Greater than Small Cup Count");
                event.preventDefault();
            }
            else{
                return true
            }
        }
    });

    setInterval(function() {
        var status = $('.part_stat').map(function(){return $(this).text()});
        var status = $.grep( jQuery.makeArray(status), function( n, i ) {
            return n == "UPLOADING" || n == "PROCESSING";
        });
        if ( status.length != 0 ) {
            $(".part_details").load("/kitting/parts/part_status/?id="+$("#page_number").attr("val"),function(data){
                load_table_sorter();
            })
        }

    }, 3000);

    setInterval(function() {
        var status = $('.part_cup_count_status').map(function(){return $(this).text()});
        var status = $.grep( jQuery.makeArray(status), function( n, i ) {
            return n == "UPLOADING" || n == "PROCESSING" || n == "UPLOADED";
        });
        if ( status.length != 0 ) {
            $(".part_cup_count_details").load("/kitting/parts/part_count_status/?id="+$("#page_no").attr("val"),function(data){
                load_table_sorter();
            })
        }

    }, 3000);

});

