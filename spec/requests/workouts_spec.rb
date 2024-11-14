require 'rails_helper'

RSpec.describe "Workouts", type: :request do
  let(:host) { create(:user) }
  let(:category) { create(:category) }
  let(:city) { create(:city) }

  let(:valid_attributes) do
    {
      title: "Morning Yoga",
      description: "A refreshing morning workout for all levels.",
      equipments: "Yoga mat, towel",
      address: "123 Main St",
      city_id: city.id,
      price_per_session: 20,
      duration_per_session: 60,
      max_participants: 10,
      host_id: host.id,
      category_id: category.id,
      is_indoor: true,
      host_present: true,
      status: "validated"
    }
  end

  let(:invalid_attributes) do
    {
      title: "",
      description: "Séance sans titre",
      address: "Paris",
      city: "Paris",
      zip_code: "75000",
      price_per_session: 10.0,
      max_participants: 10,
      host_id: 1,
      category_id: 1
    }
  end

  describe "GET /workouts" do
    before do
      create_list(:workout, 5) # Crée 5 workouts avec la factory
    end

    it "returns a list of workouts" do
      get "/workouts"

      expect(response).to have_http_status(:ok)  # 200 OK
      expect(json_response.size).to eq(5)  # 5 workouts retournés
    end
  end

  describe "GET /workouts/:id" do
    let!(:workout) { create(:workout) }

    it "returns a specific workout" do
      get "/workouts/#{workout.id}"

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(workout.id)
      expect(json_response['title']).to eq(workout.title)
    end

    it "returns a 404 error when the workout is not found" do
      get "/workouts/99999"  # ID qui n'existe pas

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /workouts" do
    before do
      sign_in host
    end
    context "with valid parameters" do
      it "creates a new Workout" do
        expect {
          post "/workouts", params: { workout: valid_attributes }
        }.to change(Workout, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    # context "with invalid parameters" do
    #   it "does not create a new Workout" do
    #     expect {
    #       post "/workouts", params: { workout: invalid_attributes }
    #     }.to change(Workout, :count).by(0)

    #     expect(response).to have_http_status(:unprocessable_entity)
    #   end
    # end
  end

  describe "PATCH /workouts/:id" do
    let!(:workout) { create(:workout) }
    let(:new_attributes) do
      { title: "Séance avancée de Yoga" }
    end

    before do
      sign_in host
    end

    it "updates a workout" do
      patch "/workouts/#{workout.id}", params: { workout: new_attributes }

      workout.reload
      expect(workout.title).to eq("Séance avancée de Yoga")
      expect(response).to have_http_status(:ok)
    end

    it "returns a 404 if the workout does not exist" do
      patch "/workouts/99999", params: { workout: new_attributes }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /workouts/:id" do
    # before do
    #   create_list(:workout, 5) # Crée 5 workouts avec la factory
    # end
    before do
      sign_in host
    end

    let!(:workout) { create(:workout) }
    it "deletes a workout" do
      expect {
        delete "/workouts/#{workout.id}"
      }.to change(Workout, :count).by(-1)

      expect(response.status).to eq(200)
    end

    it "returns a 404 if the workout does not exist" do
      delete "/workouts/99999"

      expect(response).to have_http_status(:not_found)
    end

    # it 'does not allow deletion by non-host' do
    #   another_user = create(:user)
    #   workout.update(host: another_user)

    #   sign_in another_user  # L'utilisateur actuel n'est pas l'hôte

    #   expect {
    #     delete "/workouts/#{workout.id}"
    #   }.not_to change(Workout, :count)
    # end
  end
end
