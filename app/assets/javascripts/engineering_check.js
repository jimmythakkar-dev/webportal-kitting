$(document).ready(function() {
  $("#validate_eng_check_btn").click(function() {
      $('#txtPartNo').val(function () {
          return this.value.toUpperCase();
      })
  })
});
