$(document).on('turbolinks:load', function(){
  $('.jobs.manage').ready(function(){
    jobID = /^\/farmer\/jobs\/[0-9]*\/manage/.exec(window.location.pathname)[0].split("/")[3]

    var JobWorker = Backbone.Model.extend({
      transition: function(event){
        var self = this;
        $.ajax({
          url: Routes.job_worker_transition_path({ job_worker_id: this.get("id"), transition: event }),
          method: "POST",
          success: function(data, status, jqXHR){
            self.set(data);
          },
          error: function(jqXHR, textStatus, errorThrown){
            _toastr('error', errorThrown);
          }
        })
      }
    });

    var JobWorkerCollection = Backbone.Collection.extend({
      model: JobWorker,
      url: Routes.job_workers_path(jobID)
    });

    var ShortlistWorker = Mn.View.extend({
      template: "#js-shortlist-worker",
      events: {
        "click .state-transition": "transition",
        "click .js-undo-state": "undo",
        "click .js-delete-job-worker": "delete"
      },
      className: "sixteen wide column",
      transition: function(e){
        var transition = this.$el.find('select').val();
        if(transition != ""){
          this.model.transition(transition);
        }
      },
      undo: function(e){
        e.preventDefault();
        this.model.transition("undo");
      },
      delete: function(){
        this.model.destroy();
      }
    });

    var ShortlistView = Mn.CollectionView.extend({
      childView: ShortlistWorker,
      className: "ui stackable grid",
      collectionEvents: {
        "reset": "render",
        "change": "render"
      },
      // Only show workers with whitelisted states
      filter: function (child, index, collection) {
        var state = child.get('state');
        return _.select(["shortlisted", "hired","declined","not_interested"], function(el){return el==state}).length == 1
      }
    });

    var InterestedWorker = Mn.View.extend({
      template: "#js-worker",
      events: {
        "click .js-shortlist": "shortlist",
        "click .js-delete-job-worker": "delete"
      },
      className: "ui column",
      shortlist: function(){
        this.model.transition("shortlist");
      },
      delete: function(){
        this.model.destroy();
      }
    });

    var InterestedView = Mn.CollectionView.extend({
      childView: InterestedWorker,
      className: "ui stackable three columns grid",
      collectionEvents: {
        "reset": "render",
        "change": "render"
      },
      // Only show workers with whitelisted states
      filter: function (child, index, collection) {
        return child.get('state') == "interested";
      }
    });

    var InvitedWorker = Mn.View.extend({
      template: "#js-worker",
      className: "ui column",
      events: {
        "click .js-delete-job-worker": "delete"
      },
      delete: function(){
        this.model.destroy();
      }
    });

    var InvitedView = Mn.CollectionView.extend({
      childView: InvitedWorker,
      className: "ui stackable three columns grid",
      collectionEvents: {
        "reset": "render",
        "change": "render"
      },
      // Only show workers with whitelisted states
      filter: function (child, index, collection) {
        return child.get('state') == "invited";
      }
    });

    var RecommendedWorker = Mn.View.extend({
      template: "#js-worker",
      events: {
        "click .js-invite-worker": "invite"
      },
      className: "ui column",
      invite: function(){
        this.model.invite();
      }
    });

    var RecommendedView = Mn.CollectionView.extend({
      childView: RecommendedWorker,
      className: "ui stackable three columns grid",
      collectionEvents: {
        "reset": "render",
        "change": "render"
      }
    });

    var RecommendedWorker = Backbone.Model.extend({
      invite: function(){
        var self = this;
        $.ajax({
          url: Routes.farmer_invite_worker_path(jobID),
          method: "POST",
          data: { worker_id: this.id },
          success: function(data, status, jqXHR){
            App.recommendedWorkers.remove(self.id);
            App.jobWorkers.fetch();
          },
          error: function(jqXHR, textStatus, errorThrown){
            _toastr('error', errorThrown);
          }
        })
      }
    });

    var RecommendedWorkerCollection = Backbone.Collection.extend({
      model: RecommendedWorker,
      url: Routes.farmer_job_recommended_workers_path(jobID)
    });

    var LayoutView = Mn.View.extend({
      template: "#js-manage-job-layout",
      regions: {
        shortlisted: "#shortlisted",
        interested: "#interested",
        recommended: "#recommended",
        invited: "#invited"
      },
      onRender: function(){
        this.getRegion("shortlisted").show(new ShortlistView({collection: App.jobWorkers}));
        this.getRegion("interested").show(new InterestedView({collection: App.jobWorkers}));
        this.getRegion("invited").show(new InvitedView({collection: App.jobWorkers}));
        this.getRegion("recommended").show(new RecommendedView({collection: App.recommendedWorkers}));
      }
    });

    var application = Mn.Application.extend({
      region: '#main-content',

      onStart: function() {
        App.jobWorkers = new JobWorkerCollection();
        App.jobWorkers.fetch();
        App.recommendedWorkers = new RecommendedWorkerCollection();
        App.recommendedWorkers.fetch();

        var main = this.getRegion();
        main.show(new LayoutView());
      }
    });

    window.App = new application();

    App.start();
  });
});