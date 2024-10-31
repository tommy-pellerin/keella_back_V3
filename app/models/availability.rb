class Availability < ApplicationRecord
  belongs_to :workout

  #   start_datetime = DateTime.new(start_date.year, start_date.month, start_date.day, start_time.hour, start_time.min)
  # end_datetime = start_datetime + duration.minutes
end
