function jsValidateForm()
{
    if ( document.getElementById('txt_part_number').value == "")
    {
        alert( "You must enter a part number to continue." );
        document.getElementById('txt_part_number').focus();
        return false;
    }
    return true;
}