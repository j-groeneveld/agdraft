class Workers::SessionsController < Devise::SessionsController

  def after_sign_in_path_for(resource)
    worker_dashboard_path
  end

end
