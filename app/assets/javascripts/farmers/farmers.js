$(document).on('turbolinks:load', function(){
  $('.farmers.edit').ready(function(){
    $('#edit_farmer').on('ajax:success', function(e, data, status, xhr){
      _toastr('success','Successfully updated!');
    }).on('ajax:error',function(e, xhr, status, error){
      _toastr('error',xhr.responseJSON.error);
    });
  });
});