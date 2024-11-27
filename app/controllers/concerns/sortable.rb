module Sortable
  extend ActiveSupport::Concern

  included do
    before_action :set_sort_params, only: [ :index ]
  end

  private

  def set_sort_params
    valid_sort_fields = [ "title", "city", "category", "date", "price_per_session" ]
    @sort_by = valid_sort_fields.include?(params[:sort_by]) ? params[:sort_by] : "title"
    @sort_order = params[:sort_order] == "desc" ? "desc" : "asc"
  end

  def sort(scope)
    scope.order("#{@sort_by} #{@sort_order}")
  end
end
