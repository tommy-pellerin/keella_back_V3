require 'rails_helper'

RSpec.describe "Availabilities", type: :request do
  let(:host) { create(:user) }
  before do
    host.confirm
  end
  let(:workout) { create(:workout, host: host) }
  let(:availability) { create(:availability, workout: workout) }

  # Paramètres valides pour les tests de création et de mise à jour
  let(:valid_attributes) do
    {
      workout_id: workout.id,
      date: "2024-11-10",
      start_time: "10:00",
      end_time: "11:00",
      max_participants: 5
    }
  end

  let(:invalid_attributes) do
    {
      workout_id: workout.id,
      date: nil,
      start_time: nil,
      end_time: nil,
      max_participants: nil
    }
  end

  describe "GET /availabilities" do
    before do
      create_list(:availability, 5) # Crée 5 availabilities avec la factory
    end

    it "returns a list of availabilities" do
      get "/availabilities"

      expect(response).to have_http_status(:ok)  # 200 OK
      expect(json_response.size).to eq(5)  # 5 availabilities retournés
    end
  end

  describe "GET /availabilities/:id" do
    it "returns the availability" do
      get "/availabilities/#{availability.id}"

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(availability.id)
      expect(json_response['date'].to_datetime.utc.strftime('%Y-%m-%dT%H:%M:%SZ')).to eq(availability.date.utc.strftime('%Y-%m-%dT%H:%M:%SZ'))
      expect(Time.parse(json_response['start_time']).strftime("%H:%M")).to eq(availability.start_time.strftime("%H:%M"))
      expect(Time.parse(json_response['end_time']).strftime("%H:%M")).to eq(availability.end_time.strftime("%H:%M"))
    end

    it "returns a 404 error if the availability is not found" do
      get "/availabilities/99999"  # ID non-existant

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /availabilities" do
    context "when not authenticated" do
      it "does not allow creating a new Availability" do
        expect {
          post "/availabilities", params: { availability: valid_attributes }
        }.not_to change(Availability, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid parameters when authenticated" do
      before do
        sign_in host
      end

      it "creates a new Availability" do
        expect {
          post "/availabilities", params: { availability: valid_attributes }
        }.to change(Availability, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['workout_id']).to eq(valid_attributes[:workout_id])
      end
    end

    context "with invalid parameters when authenticated" do
      before do
        sign_in host
      end

      let(:invalid_attributes) { valid_attributes.merge(date: nil) }

      it "does not create a new Availability" do
        expect {
          post "/availabilities", params: { availability: invalid_attributes }
        }.not_to change(Availability, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /availabilities/:id" do
    context "when user is host," do
      before { sign_in host }

      it "updates an availability with valid parameters" do
        updated_attributes = { date: "2024-11-12", start_time: "11:00", end_time: "12:00", max_participants: 10 }

        patch "/availabilities/#{availability.id}", params: { availability: updated_attributes }

        availability.reload
        expect(response).to have_http_status(:ok)
        expect(availability.date.to_date).to eq(Date.parse(updated_attributes[:date]))
        expect(availability.start_time.strftime("%H:%M")).to eq(updated_attributes[:start_time])
        expect(availability.end_time.strftime("%H:%M")).to eq(updated_attributes[:end_time])
      end

      it "does not update an availability with invalid parameters" do
        patch "/availabilities/#{availability.id}", params: { availability: { date: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
        availability.reload
        expect(availability.date).not_to eq(nil)
      end
    end

    context "when user is not host," do
      let(:another_user) { create(:user) }
      it 'does not allow update by non-host' do
        sign_in another_user  # L'utilisateur actuel n'est pas l'hôte

        updated_attributes = { date: "2024-11-12", start_time: "11:00", end_time: "12:00", max_participants: 10 }

        patch "/availabilities/#{availability.id}", params: { availability: updated_attributes }
        availability.reload
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /availabilities/:id" do
    let!(:availability) { create(:availability, valid_attributes) }

    context "when user is host," do
      before do
        sign_in host
      end

      it "deletes an availability" do
        expect {
          delete "/availabilities/#{availability.id}"
        }.to change(Availability, :count).by(-1)

        expect(response.status).to eq(200)
      end

      it "returns a 404 error if the availability does not exist" do
        delete "/availabilities/99999"  # ID non-existant

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is not host," do
      let(:another_user) { create(:user) }
      it 'does not allow deletion by non-host' do
        sign_in another_user  # L'utilisateur actuel n'est pas l'hôte

        expect {
          delete "/availabilities/#{availability.id}"
        }.not_to change(Availability, :count)
      end
    end
  end
end
