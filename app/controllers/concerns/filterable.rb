module Filterable
  extend ActiveSupport::Concern

  included do
    before_action :set_filter_params, only: [ :index ]
  end

  private

  def set_filter_params
    @city_id = params[:city_id]
    @category_id = params[:category_id]
    @date = params[:date]
    @available_slots = params[:available_slots]
  end

  def filter(scope)
    scope = scope.joins(:availabilities).where("availabilities.date >= ?", DateTime.now)
    scope = scope.where(city_id: @city_id) if @city_id.present?
    scope = scope.where(category_id: @category_id) if @category_id.present?
    scope = scope.joins(:availabilities).where("availabilities.date = ?", @date) if @date.present?
    if @available_slots.present?
      scope = scope.joins(:availabilities).where("availabilities.id IN (?)", Availability.select(:id).select { |a| a.available_slots >= @available_slots.to_i })
    end
    scope
  end
end
