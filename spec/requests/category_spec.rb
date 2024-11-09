require 'rails_helper'

RSpec.describe "Categories", type: :request do
  describe "GET /categories" do
    before do
      create_list(:category, 5)  # Crée 5 catégories avec la factory
    end

    it "returns a list of categories" do
      get "/categories"

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(5)  # Vérifie qu'on a bien 5 catégories retournées
    end
  end

  describe "GET /categories/:id" do
    let(:category) { create(:category) }  # Crée une catégorie pour le test

    it "returns a specific category" do
      get "/categories/#{category.id}"

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(category.id)
      expect(json_response['title']).to eq(category.title)
    end

    it "returns a 404 error when the category is not found" do
      get "/categories/99999"  # ID qui n'existe pas

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /categories" do
    let(:valid_attributes) { { title: "Quidditch" } }  # Attributs valides pour la création
    let(:invalid_attributes) { { title: "" } }  # Exemple d'attributs invalides

    context "with valid parameters" do
      it "creates a new category" do
        expect {
          post "/categories", params: { category: valid_attributes }
        }.to change(Category, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['title']).to eq("Quidditch")
      end
    end

    context "with invalid parameters" do
      it "does not create a new category" do
        expect {
          post "/categories", params: { category: invalid_attributes }
        }.not_to change(Category, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT /categories/:id" do
    let(:category) { create(:category, title: "Pilates") }
    let(:new_attributes) { { title: "Advanced Pilates" } }

    context "with valid parameters" do
      it "updates the category" do
        put "/categories/#{category.id}", params: { category: new_attributes }

        expect(response).to have_http_status(:ok)
        expect(category.reload.title).to eq("Advanced Pilates")  # Vérifie que le nom a bien été mis à jour
      end
    end

    context "with invalid parameters" do
      it "does not update the category" do
        put "/categories/#{category.id}", params: { category: { title: "" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(category.reload.title).to eq("Pilates")  # Le nom doit rester inchangé
      end
    end
  end

  describe "DELETE /categories/:id" do
    let!(:category) { create(:category) }  # Utilise `!` pour la création immédiate

    it "deletes the category" do
      expect {
        delete "/categories/#{category.id}"
      }.to change(Category, :count).by(-1)

      expect(response).to have_http_status(:ok)  # Vérifie un statut 204 pour suppression réussie
    end

    it "returns a 404 when the category is not found" do
      delete "/categories/99999"  # ID inexistant

      expect(response).to have_http_status(:not_found)
    end
  end
end
