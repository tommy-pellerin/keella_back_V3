# require 'rails_helper'

# RSpec.describe "Availabilities", type: :request do
#   let(:workout) { create(:workout) }
#   let(:availability) { create(:availability, workout: workout) }

#   # Paramètres valides pour les tests de création et de mise à jour
#   let(:valid_attributes) do
#     {
#       workout_id: workout.id,
#       start_date: "2024-11-10",
#       start_time: "10:00",
#       end_date: "2024-11-20",
#       duration: 120,
#       is_booked: false
#     }
#   end

#   let(:invalid_attributes) do
#     {
#       start_date: nil,
#       start_time: nil,
#       end_date: nil,
#       duration: nil
#     }
#   end

#   describe "GET /availabilities/:id" do
#     it "returns the availability" do
#       get "/availabilities/#{availability.id}"

#       expect(response).to have_http_status(:ok)
#       expect(json_response['id']).to eq(availability.id)
#       expect(json_response['start_date']).to eq(availability.start_date.to_s)
#       expect(json_response['start_time']).to eq(availability.start_time.strftime("%H:%M"))
#       expect(json_response['end_time']).to eq(availability.end_time.strftime("%H:%M"))
#     end

#     it "returns a 404 error if the availability is not found" do
#       get "/availabilities/99999"  # ID non-existant

#       expect(response).to have_http_status(:not_found)
#     end
#   end
# end
