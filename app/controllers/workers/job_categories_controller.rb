class Workers::JobCategoriesController < Workers::BaseController
  def create
    current_worker.job_categories << JobCategory.find_by!(secure_params)
    render_201
  end

  def destroy
    job_category = current_worker.job_categories.find(params[:id])
    if current_worker.job_categories.destroy(job_category)
      return render_204
    end
    render_404
  end

  protected

  def secure_params
    params.require(:job_category).permit(:id)
  end
end