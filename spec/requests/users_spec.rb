require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:tester) { create(:user) }

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
        # expect(response.body).to include("Something went wrong.")
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
      before { sign_in(tester) }
      it "returns a specific user" do
        get "/users/#{tester.id}"

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(tester.id)
        expect(response.body).to include(tester.email)
      end

      it "returns limited data for other users" do
        other_user = create(:user)
        get "/users/#{other_user.id}"

        expect(response).to have_http_status(:ok)
        expect(json_response.keys).not_to include("email", "phone")
      end

      it "when the user is not found, returns a 404 error" do
        get "/users/99999"  # ID qui n'existe pas

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the user is not authenticated" do
      it "returns a 401 Unauthorized error" do
        # Pas de token d'authentification
        get "/users/#{tester.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /users/:id" do
    let(:valid_update_params) do
      {
        user: {
          first_name: "UpdatedFirstName",
          last_name: "UpdatedLastName",
          birthday: "2000-01-01",
          phone: "0612345678",
          professional: true
        }
      }
    end

    let(:invalid_update_params) do
      {
        user: {
          first_name: "",
          phone: "invalid_phone"
        }
      }
    end

    context "when the user is authenticated but not an admin" do
      let(:another_user) { create(:user) }
      before { sign_in tester }

      it "updates the user's personal information with valid parameters" do
        patch "/users/#{tester.id}", params: valid_update_params

        expect(response).to have_http_status(:ok)
        expect(json_response['user']['first_name']).to eq("UpdatedFirstName")
        expect(json_response['user']['phone']).to eq("0612345678")
      end
      it "can not updates the user's personal information with invalid parameters" do
        patch "/users/#{tester.id}", params: invalid_update_params

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not allow a user to modify another user's profile" do
        patch "/users/#{another_user.id}", params: { user: { first_name: "Malicious Name" } }

        expect(response).to have_http_status(:unauthorized)
        expect(another_user.reload.first_name).not_to eq("Malicious Name")
      end

      it "cannot update admin rights" do
        patch "/users/#{tester.id}", params: { user: { is_admin: true } }

        # Vérifie que la réponse retourne une erreur
        expect(response).to have_http_status(:unauthorized)

        # Vérifie que l'attribut is_admin n'a pas changé
        tester.reload
        expect(tester.is_admin).to be_falsey
      end
    end

    context "when the user is an authenticated admin" do
      let(:admin) { create(:user, is_admin: true) }
      before { sign_in admin }

      it "allows an admin to update another user's information" do
        patch "/users/#{tester.id}", params: { user: { first_name: "New Name" } }

        expect(response).to have_http_status(:ok)
        expect(tester.reload.first_name).to eq("New Name")
      end

      it "allows an admin to update another user's is_admin field" do
        patch "/users/#{tester.id}", params: { user: { is_admin: true } }

        expect(response).to have_http_status(:ok)
        expect(tester.reload.is_admin).to be_truthy
      end
    end

    context "when the user is not authenticated" do
      it "updates the user's personal information with valid parameters" do
        patch "/users/#{tester.id}", params: valid_update_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # Test du changement d'email (connecté)
  describe "PATCH /users" do
    let(:valid_email_update_params) do
      {
        user: {
          email: "new_email@example.com",
          current_password: tester.password  # Nécessaire pour la vérification de mot de passe
        }
      }
    end

    let(:invalid_email_update_params) do
      {
        user: {
          email: "invalid_email",
          current_password: tester.password
        }
      }
    end

    context "when the user is authenticated" do
      before { sign_in tester }

      it "updates the user's email with valid parameters" do
        patch "/users", params: valid_email_update_params

        expect(response).to have_http_status(:ok)
        tester.reload
        # Vérifie que l'email a été mis à jour dans `unconfirmed_email`
        expect(tester.unconfirmed_email).to eq("new_email@example.com")
        # Vérifie que le token de confirmation a été généré
        expect(tester.confirmation_token).not_to be_nil

        # Vérifie que l'email de confirmation a bien été envoyé
        # (tu peux utiliser `ActionMailer::Base.deliveries` pour vérifier les emails envoyés)
        # expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.last.to).to include("new_email@example.com")
      end

      it "does not update the user's email with invalid parameters" do
        patch "/users", params: invalid_email_update_params

        expect(response).to have_http_status(:unprocessable_entity)
        # expect(json_response['errors']).to include("Email is invalid")
      end

      it "does not update the user's email with the same email" do
        patch "/users", params: {
          user: { current_password: tester.password, email: tester.email }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        # expect(json_response['error']).to eq("L'email fourni est identique à l'email actuel.")
      end

      it 'does not update the email with incorrect current password' do
        # Tentative de mise à jour avec un mot de passe incorrect
        patch "/users", params: { user: { current_password: 'wrongpassword', email: 'new_email@example.com' } }

        # L'utilisateur ne doit pas avoir mis à jour son email
        tester.reload
        expect(tester.unconfirmed_email).not_to eq('new_email@example.com')

        # Vérifie que le message d'erreur est renvoyé
        expect(response.status).to eq(422)
        # expect(response.body).to include('is not correct')
      end
    end
  end

  # Test du changement de mot de passe (connecté)
  describe "PATCH /users" do
    before do
      sign_in tester
    end

    context "when the current password is correct" do
      it "updates the password successfully" do
        patch "/users", params: {
          user: {
            current_password: "password123",
            password: "newpassword",
            password_confirmation: "newpassword"
          }
        }
        expect(response).to have_http_status(:ok)
        # expect(JSON.parse(response.body)["message"]).to eq("Le mot de passe a été changé avec succès.")
      end
    end

    context "when the current password is incorrect" do
      it "returns an error" do
        patch "/users", params: {
          user: {
            current_password: "wrongpassword",
            password: "newpassword",
            password_confirmation: "newpassword"
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        # expect(JSON.parse(response.body)["errors"]).to include("Current password is invalid")
      end
    end

    context "when the new password is too short" do
      it "returns an error" do
        patch "/users", params: {
          user: {
            current_password: "password123",
            password: "short",
            password_confirmation: "short"
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        # expect(JSON.parse(response.body)["errors"]).to include("Password is too short")
      end
    end

    context "when the password confirmation does not match" do
      it "returns an error" do
        patch "/users", params: {
          user: {
            current_password: "password123",
            password: "newpassword",
            password_confirmation: "differentpassword"
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        # expect(JSON.parse(response.body)["errors"]).to include("Password confirmation doesn't match Password")
      end
    end

    context "when required parameters are missing" do
      it "returns an error for missing current password" do
        patch "/users", params: {
          user: {
            password: "newpassword",
            password_confirmation: "newpassword"
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        # expect(JSON.parse(response.body)["errors"]).to include("Current password can't be blank")
      end
    end
  end

  # Test de la demande de reset du mot de passe (mot de passe oublié)
  describe "POST /users/password" do
    let(:valid_email_params) { { user: { email: tester.email } } }
    let(:invalid_email_params) { { user: { email: "wrong@example.com" } } }

    it "should send reset password instructions if email is valid" do
      post user_password_path, params: valid_email_params
      expect(response).to have_http_status(:ok)
      # expect(JSON.parse(response.body)["message"]).to eq("Un email de réinitialisation a été envoyé.")
    end

    it "should return error if email is invalid" do
      post user_password_path, params: invalid_email_params
      expect(response).to have_http_status(:unprocessable_entity)
      # expect(JSON.parse(response.body)["errors"]).to include("Email not found")
    end
  end

  # Test de la confirmation du mot de passe (mot de passe oublié, réinitialisation via token)
  describe "PATCH /users/password" do
    before do
      sign_in tester
    end
    let(:reset_token) { tester.send_reset_password_instructions }
    let(:new_password) { "newpassword123" }
    let(:password_confirmation) { new_password }

    it "met à jour le mot de passe lorsque le token est valide et que les mots de passe correspondent" do
      patch user_password_path, params: {
        user: {
          reset_password_token: reset_token,
          password: new_password,
          password_confirmation: password_confirmation
        }
      }

      tester.reload
      expect(response).to have_http_status(:ok)
      # expect(JSON.parse(response.body)["message"]).to eq("Votre mot de passe a été mis à jour avec succès.")
      expect(tester.valid_password?(new_password)).to be_truthy
    end

    it "renvoie une erreur si les mots de passe ne correspondent pas" do
      patch user_password_path, params: {
        user: {
          reset_password_token: reset_token,
          password: new_password,
          password_confirmation: "wrongpassword"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      # expect(JSON.parse(response.body)["errors"]).to include("Password confirmation doesn't match Password")
    end
  end
end
