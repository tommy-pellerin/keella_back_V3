require 'rails_helper'

RSpec.describe Availability, type: :model do
  let(:availability) { build(:availability) }

  # Validations
  describe 'validations' do
    # Présence des attributs requis
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:duration) }

    # Durée minimale de 30 minutes
    it { should validate_numericality_of(:duration).is_greater_than(30) }

    # Boolean pour is_booked
    it { should allow_value(true).for(:is_booked) }
    it { should allow_value(false).for(:is_booked) }
  end

  # Associations
  describe 'associations' do
    it { should belong_to(:workout) }
  end

  # Méthode
  describe 'methods' do
    context 'when end_date is not after start_date and start_time' do
      it 'is not valid' do
        availability.start_date = Date.today
        availability.start_time = Time.now
        availability.end_date = Date.today # ici end_date est défini à la même date, donc avant la combinaison de start_date et start_time

        expect(availability).not_to be_valid # Vérifie simplement l'invalidité
      end
    end
  end
end
