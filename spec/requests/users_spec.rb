require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:tester) { create(:user) }

  let(:valid_attributes) do
    {
      # name: "John Doe",
      email: "john@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  let(:invalid_attributes) do
    {
      # name: "",
      email: "invalidemail",
      password: "123",
      password_confirmation: "123"
    }
  end

  describe "GET /users" do
    before do
      create_list(:user, 5)  # Crée 5 catégories avec la factory
    end

    it "returns a list of users" do
      sign_in tester

      get "/users"

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(6)  # Vérifie qu'on a bien 5 catégories retournées
    end
  end

  # describe "GET /users/:id" do
  #   context "when the user is authenticated" do
  #     it "returns a specific user" do
  #       sign_in tester

  #       get "/users/#{tester.id}"

  #       expect(response).to have_http_status(:ok)
  #       expect(json_response['id']).to eq(tester.id)
  #       expect(response.body).to include(user.email)
  #     end
  #   end

  #   context "when the user is not authenticated" do
  #     it "returns a 401 Unauthorized error" do
  #       # Pas de token d'authentification
  #       get "/users/#{tester.id}"

  #       expect(response).to have_http_status(:unauthorized)
  #     end
  #   end

  #   context "when the user is not found" do
  #     it "returns a 404 error" do
  #       get "/users/99999"  # ID qui n'existe pas

  #       expect(response).to have_http_status(:not_found)
  #     end
  #   end
  # end

  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post "/users", params: { user: valid_attributes }
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)
      end

      it 'creates a user and sends a confirmation email' do
        # Comptabilise les emails envoyés avant l'inscription
        expect {
          post '/users', params: { user: valid_attributes }
        }.to change(ActionMailer::Base.deliveries, :count).by(1)  # Vérifie qu'un email a été envoyé

        # Vérifie que l'email envoyé est un email de confirmation
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to include('john@example.com')  # Vérifie que l'email est envoyé à l'utilisateur
        expect(email.body.encoded).to include('confirmation_token')  # Vérifie que le corps de l'email inclut un token
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post "/users", params: { user: invalid_attributes }
        }.to change(User, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Something went wrong.")
      end
    end
  end
end
