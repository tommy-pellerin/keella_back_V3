require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:tester) { create(:user) }
  before do
    tester.confirm
  end
  let(:city) { create(:city) }

  let(:valid_attributes) do
    {
      email: "john@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
      phone: "0601020304",
      id_verified: [ true, false ].sample,
      professional: [ true, false ].sample,
      is_admin: false,
      # Association avec la factory `City`
      city_id: city.id  # Assure-toi d'utiliser `city_id` et pas `city`
    }
  end

  let(:invalid_attributes) do
    {
      email: "invalidemail",
      password: "123",
      password_confirmation: "123",
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
      phone: "0601020304",
      id_verified: [ true, false ].sample,
      professional: [ true, false ].sample,
      is_admin: false,
      # Association avec la factory `City`
      city_id: city.id
    }
  end

  # Tester l'inscription
  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post "/users", params: { user: valid_attributes }
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)

        # Vérifie que l'utilisateur est créé et contient les bons attributs
        user = User.last
        expect(user.email).to eq(valid_attributes[:email])
        expect(user.first_name).to eq(valid_attributes[:first_name])
        expect(user.last_name).to eq(valid_attributes[:last_name])
        expect(user.phone).to eq(valid_attributes[:phone])
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

  # Tester la Connexion (POST /users/sign_in)
  describe "POST /users/sign_in" do
    context "with valid credentials" do
      it "returns a 200 status and token" do
        post "/users/sign_in", params: { user: { email: tester.email, password: tester.password } }

        # Vérifie que la réponse a un statut 200 (OK)
        expect(response).to have_http_status(:ok)

        # Vérifie que le token JWT est renvoyé dans les en-têtes (Authorization)
        expect(response.headers['Authorization']).to be_present
      end
    end

    context "with invalid credentials" do
      it "returns a 401 status with an error message" do
        # Envoie des paramètres incorrects
        post "/users/sign_in", params: { user: { email: tester.email, password: "wrongpassword" } }

        # Vérifie que la réponse a un statut 401 (Unauthorized)
        expect(response).to have_http_status(:unauthorized)

        # Vérifie qu'un message d'erreur est renvoyé
        expect(response.body).not_to be_empty # Vérifie que la réponse contient un message
      end
    end
  end

  # Tester la Déconnexion (DELETE /users/sign_out)
  describe "DELETE /users/sign_out" do
    context "when no user is logged in" do
      it "returns an error" do
        delete "/users/sign_out"

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).not_to be_empty
      end
    end

    # context "when the user is logged in," do
    #   let(:token) do
    #     post "/users/sign_in", params: { user: { email: tester.email, password: tester.password } }
    #     response.headers['Authorization']
    #   end

    #   it "logs out the user and invalidates the token" do
    #     delete "/users/sign_out", headers: { 'Authorization' => "#{token}" }

    #     expect(response).to have_http_status(:ok)
    #     expect(response.body).not_to be_empty
    #   end
    # end
  end

  describe "GET /users" do
    before do
      create_list(:user, 5)  # Crée 5 catégories avec la factory
    end

    before do
      sign_in tester
    end

    it "returns a list of users" do
      get "/users"

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(6)  # Vérifie qu'on a bien 5 catégories retournées
    end
  end

  describe "GET /users/:id" do
    context "when the user is authenticated" do
      it "returns a specific user" do
        sign_in tester

        get "/users/#{tester.id}"

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(tester.id)
        expect(response.body).to include(tester.email)
      end
    end

    context "when the user is not authenticated" do
      it "returns a 401 Unauthorized error" do
        # Pas de token d'authentification
        get "/users/#{tester.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when the user is not found" do
      it "returns a 404 error" do
        sign_in tester
        get "/users/99999"  # ID qui n'existe pas

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
