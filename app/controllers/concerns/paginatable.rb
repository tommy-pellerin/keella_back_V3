module Paginatable
  extend ActiveSupport::Concern

  included do
    before_action :set_pagination_params, only: [ :index ]
  end

  private

  def set_pagination_params
    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || 10).to_i
  end

  def paginate(scope)
    total_count = scope.count
    total_pages = (total_count / @per_page.to_f).ceil
    paginated_scope = scope.offset((@page - 1) * @per_page).limit(@per_page)

    {
      current_page: @page,
      per_page: @per_page,
      total_count: total_count,
      total_pages: total_pages,
      records: paginated_scope
    }
  end
end
