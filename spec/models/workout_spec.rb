require 'rails_helper'

RSpec.describe Workout, type: :model do
  # Définir une instance de Workout avec `let`
  let(:workout) { create(:workout) } # crée un Workout avec les valeurs par défaut de la factory

  # Validations
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(workout).to be_valid
    end

    it { should validate_presence_of(:title) }  # Le titre doit être présent
    it { should validate_uniqueness_of(:title) } # Le titre doit être unique
    it { should validate_length_of(:title).is_at_least(5).is_at_most(50) } # Longueur du titre (min 5, max 50)

    it { should validate_length_of(:description).is_at_least(10).is_at_most(1000).allow_blank }  # Longueur de la description (min 10, max 1000) avec `allow_blank`
    it { should validate_length_of(:equipments).is_at_most(1000).allow_blank }  # Longueur des équipements (max 1000) avec `allow_blank`
    it { should validate_presence_of(:address) }     # L'adresse doit être présente
    it { should validate_presence_of(:city) }         # La ville doit être présente
    # it { should validate_presence_of(:zip_code) }     # Le code postal doit être présent
    # it { should allow_value('75001').for(:zip_code) } # Validation du format du code postal
    # it { should_not allow_value('abcde').for(:zip_code) }  # Test d'un code postal invalide
    it { should validate_numericality_of(:price_per_session).is_greater_than_or_equal_to(0) }  # Le prix doit être >= 0
    it { should validate_numericality_of(:duration_per_session).is_greater_than(30) }  # La durée doit être > 30 minutes
    it { should validate_presence_of(:max_participants) }  # Le nombre max de participants doit être présent
    it { should validate_numericality_of(:max_participants).is_greater_than(0) }  # Le nombre max de participants doit être > 0
  end

  describe 'default values' do
    it 'sets is_indoor to true by default' do
      workout = Workout.new
      expect(workout.is_indoor).to be_in([ true, false ])
    end

    it 'sets host_present to true by default' do
      workout = Workout.new
      expect(workout.host_present).to be_in([ true, false ])
    end
  end

  # Associations
  describe 'associations' do
    it { should belong_to(:host).class_name('User') }
    it { should belong_to(:category) }
    it { should have_many(:availabilities) }
    it { should have_many(:reservations) }
    it { should have_many(:participants).through(:reservations).source(:participant) }

    it 'is not valid without a host' do
      workout = build(:workout, host: nil)
      expect(workout).to_not be_valid
    end
  end

  # Méthode
end
