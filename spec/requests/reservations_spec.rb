require 'rails_helper'

RSpec.describe "Reservations", type: :request do
  let(:user) { create(:user) }
  let(:availability) { create(:availability) }
  before do
    sign_in user
  end
  # Paramètres valides pour les tests de création et de mise à jour
  let(:valid_attributes) do
    {
      availability_id: availability.id,
      quantity: 2
    }
  end

  let(:invalid_attributes) do
    {
      availability_id: availability.id,
      quantity: 0
    }
  end

  describe "GET /reservations" do
    before do
      create_list(:reservation, 5)
    end

    it "returns a list of reservations" do
      get "/reservations"

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(5)
    end
  end

  describe "GET /reservations/:id" do
    let(:user) { create(:participant) }
    let(:availability) { create(:availability) }
    let(:reservation) { create(:reservation, participant: user, availability: availability) }

    before do
      sign_in user
    end

    it "returns a specific reservation" do
      get "/reservations/#{reservation.id}"

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(reservation.id)
      expect(json_response['participant_id']).to eq(user.id)
    end

    it "returns a 404 error when the reservation is not found" do
      get "/reservations/99999" # ID inexistant

      expect(response).to have_http_status(:not_found)
    end
  end

  # describe "GET /users/:user_id/reservations" do
  #   let(:user) { create(:user) }
  #   let(:workout) { create(:workout) }
  #   let!(:reservation1) { create(:reservation, user: user, workout: workout) }
  #   let!(:reservation2) { create(:reservation, user: user, workout: workout) }

  #   before do
  #     sign_in user
  #   end

  #   it "returns all reservations for a user" do
  #     get "/users/#{user.id}/reservations"

  #     expect(response).to have_http_status(:ok)
  #     expect(json_response.size).to eq(2)  # Deux réservations créées
  #   end
  # end

  describe "POST /reservations" do
    context "with invalid parameters" do
      it "creates a reservation" do
        expect {
          post "/reservations", params: { reservation: valid_attributes }
        }.to change(Reservation, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['availability_id']).to eq(availability.id)
      end

      # it "does not create a reservation for a full workout" do
      #   workout.update(max_participants: 0) # Supposons que le workout soit complet

      #   expect {
      #     post "/reservations", params: { reservation: { workout_id: workout.id } }
      #   }.not_to change(Reservation, :count)

      #   expect(response).to have_http_status(:unprocessable_entity)
      #   expect(json_response['error']).to eq("Workout is already full")
      # end
    end

    context "with invalid parameters" do
      it "does not create a new reservation" do
        expect {
          post "/reservations", params: { reservation: invalid_attributes }
        }.to change(Reservation, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
