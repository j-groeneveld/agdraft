$(document).on('turbolinks:load', function(){
  $('.workers.show').ready(function(){
    workerID = /^\/workers\/[0-9]*/.exec(window.location.pathname)[0].split("/")[2]
    $("#invite-worker").on("click", function(e){
      var button = $(e.target);
      $(".modal").modal('show');
    });
    $(".js-invite-worker").on("click", function(){
      $(this).toggleClass("disabled");
      $.ajax({
        url: Routes.farmer_shortlist_worker_path($(this).data('id')),
        method: "POST",
        data: {worker_id: workerID},
        success: function(data, status){
          toastr.success("Worker invited to job!");
        },
        error: function(jqXHR, textStatus, errorThrown){
          $(this).toggleClass("disabled");
          toastr.error(errorThrown);
        }
      });
    });
  });
});