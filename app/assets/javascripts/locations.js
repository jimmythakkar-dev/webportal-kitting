$("#location_name").keyup(function() {
    var value =$(this).val();
    var word = "";
    var regexp = /[a-zA-Z0-9\s\-\.\/]/;

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
