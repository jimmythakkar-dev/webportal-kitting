jQuery(document).ready (function(){
    jQuery('.language_option .select_language').click (function(){
        jQuery('.language_option ul.sub_lang').slideToggle(200);
    });
});