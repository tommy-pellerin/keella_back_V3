require 'rails_helper'

RSpec.describe Category, type: :model do
  # Définir une instance de Category avec `let`
  let(:category) { create(:category) } # crée un Category avec les valeurs par défaut de la factory

  # Validations
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(category).to be_valid # vérifie que l'instance est valide
    end

    it 'is not valid without a title' do
      category.title = nil
      expect(category).to_not be_valid
    end

    context 'when title is not unique' do
      it 'is not valid with a duplicate title' do
        duplicate_category = build(:category, title: category.title) # Construit une categorie sans la sauvegarder
        expect(duplicate_category).not_to be_valid           # Vérifie qu'elle est invalide
      end
    end
  end

  # Associations
  describe 'associations' do
    it { should have_many(:workouts) }
  end
end
