# frozen_string_literal: true
class Backend::LeaveTimesController < Backend::BaseController
  before_action :set_query_object

  def index
    @users = User.all
  end

  private

  def set_query_object
    @q = LeaveTime.ransack(search_params)
  end

  def collection_scope
    if params[:id]
      LeaveTime.preload(:user, leave_time_usages: :leave_application)
    else
      @q.result.preload(:user)
    end
  end

  def resource_params
    params.require(:leave_time).permit(
      :user_id, :leave_type, :quota, :effective_date, :expiration_date, :usable_hours, :used_hours, :remark
    )
  end

  def search_params
    params.fetch(:q, {})&.permit(:s, :leave_type_eq, :effective_true, :user_id_eq)
  end

  def url_after(action)
    if @actions.include?(action)
      url_for(action: :index, leave_type: leave_type)
    else
      request.env['HTTP_REFERER']
    end
  end
end
