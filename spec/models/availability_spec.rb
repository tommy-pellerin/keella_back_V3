require 'rails_helper'

RSpec.describe Availability, type: :model do
  let(:availability) { build(:availability) }

  # Validations
  describe 'validations' do
    # Présence des attributs requis
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should validate_presence_of(:max_participants) }  # Le nombre max de participants doit être présent
    it { should validate_numericality_of(:max_participants).is_greater_than(0) }  # Le nombre max de participants doit être > 0
    # it { should validate_presence_of(:duration) }

    # Durée minimale de 30 minutes
    # it { should validate_numericality_of(:duration).is_greater_than(30) }

    # Boolean pour is_booked
    it { should allow_value(true).for(:is_booked) }
    it { should allow_value(false).for(:is_booked) }
  end

  # Associations
  describe 'associations' do
    it { should belong_to(:workout) }
    it { should have_many(:reservations) }
    it { should have_many(:participants).through(:reservations).source(:participant) }
  end

  # Méthode
  describe 'methods' do
    context 'when end_time is not after start_time' do
      it 'is not valid' do
        availability.end_time = availability.start_time # ici end_time est défini à la même heure

        expect(availability).not_to be_valid # Vérifie simplement l'invalidité
      end
    end
  end
end
