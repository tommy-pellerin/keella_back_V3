require 'rails_helper'

RSpec.describe "Reservations", type: :request do
  let(:user) { create(:user) }
  before do
    user.confirm
  end
  let(:availability) { create(:availability, max_participants: 5) }
  before do
    sign_in user
  end
  # Paramètres valides pour les tests de création et de mise à jour
  let(:valid_attributes) do
    {
      availability_id: availability.id,
      quantity: 2,
      status: "accepted"
    }
  end

  let(:invalid_attributes) do
    {
      availability_id: availability.id,
      quantity: nil,
      status: "accepted"
    }
  end

  describe "GET /reservations" do
    before do
      create_list(:reservation, 5, quantity: 1)
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
    context "with valid parameters" do
      it "creates a reservation" do
        expect {
          post "/reservations", params: { reservation: valid_attributes }
        }.to change(Reservation, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['availability_id']).to eq(availability.id)
      end
    end

    context 'when trying to reserve more than available slots' do
      it 'adds an error if the requested quantity exceeds available slots' do
        create(:reservation, availability: availability, quantity: 3)  # réserver 3 places
        new_reservation = build(:reservation, availability: availability, quantity: 4)  # essayer de réserver 4 places

        expect(new_reservation).to be_invalid
        # expect(new_reservation.errors[:quantity]).to include("Il ne reste que 2 places disponibles.")  # car il y a déjà 3 places réservées, il ne reste que 2 places
      end
    end

    context 'when the availability is full' do
      it 'does not allow new reservations if no slots are available' do
        create(:reservation, availability: availability, quantity: 5)  # réserver toutes les places
        new_reservation = build(:reservation, availability: availability, quantity: 1)

        expect(new_reservation).to be_invalid
        # expect(new_reservation.errors[:quantity]).to include("Il ne reste que 0 places disponibles.")  # car le créneau est complet
      end
    end

    context "with invalid parameters" do
      it "does not create a reservation with missing quantity" do
        expect {
          post "/reservations", params: { reservation: { availability_id: availability.id } }
        }.not_to change(Reservation, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        # expect(response.body).to include("Quantity can't be blank")
      end

      it "does not create a reservation with quantity less than 1" do
        expect {
          post "/reservations", params: { reservation: { availability_id: availability.id, quantity: 0 } }
        }.not_to change(Reservation, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        # expect(response.body).to include("Quantity must be greater than 0")
      end

      it "does not create a reservation with negative quantity" do
        expect {
          post "/reservations", params: { reservation: { availability_id: availability.id, quantity: -1 } }
        }.not_to change(Reservation, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        # expect(response.body).to include("Quantity must be greater than 0")
      end
    end
  end

  describe "PATCH /reservations/:id" do
    let!(:reservation) { create(:reservation, participant: user, status: "pending", quantity: 3) }  # Créer une réservation avec 3 places

    context "when updating the status" do
      it "successfully updates the status" do
        patch "/reservations/#{reservation.id}", params: { reservation: { status: "accepted" } }

        expect(response).to have_http_status(:ok)
        expect(reservation.reload.status).to eq("accepted")
      end
    end

    context "when trying to update the quantity" do
      it "does not allow changing the quantity" do
        patch "/reservations/#{reservation.id}", params: { reservation: { quantity: 4 } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(reservation.reload.quantity).to eq(3)  # La quantité ne doit pas avoir changé
        # expect(json_response['errors']).to include("Vous ne pouvez pas changer la quantité après la création de la réservation.")
      end
    end
  end

  describe "Reservations DELETE /reservations/:id" do
    let!(:reservation) { create(:reservation, availability: availability, participant: user, quantity: 2) }

    context "when the reservation exists" do
      it "successfully deletes the reservation" do
        expect {
          delete "/reservations/#{reservation.id}"
        }.to change(Reservation, :count).by(-1)  # Vérifie que le nombre de réservations diminue de 1

        expect(response).to have_http_status(:ok)
        # expect(json_response['message']).to eq("Réservation supprimée avec succès.")
      end
    end

    context "when the reservation does not exist" do
      it "returns a 404 error" do
        delete "/reservations/999999"  # ID inexistant

        expect(response).to have_http_status(:not_found)
        # expect(json_response['errors']).to include("Couldn't find Reservation with 'id'=999999")
      end
    end
  end
end
