require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:reservation) { build(:reservation) }

  # Validations
  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:workout) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { should validate_presence_of(:status) }
  end

  # Associations
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:workout) }
  end

  describe 'enum attributes' do
    it { should define_enum_for(:status).with_values([ :pending, :accepted, :refused, :host_cancelled, :user_cancelled, :closed, :expired ]) }
    it { should define_enum_for(:cancellation_reason).with_values([ :personal_reasons, :scheduling_conflict, :illness, :found_alternative, :financial_reasons, :other ]) }
  end

  # Méthode
  describe 'callbacks' do
    context 'before_create' do
      it 'sets the total price based on workout price and quantity' do
        workout = create(:workout, price_per_session: 100)
        reservation = build(:reservation, workout: workout, quantity: 3)

        reservation.save
        expect(reservation.total).to eq(300)
      end
    end

    context 'after_update' do
      it 'updates status_changed_at when the status changes' do
        reservation = create(:reservation, status: :pending)
        original_time = reservation.status_changed_at

        # Attendre un instant pour que le changement de temps soit perceptible
        sleep(1)
        reservation.update(status: :accepted)

        expect(reservation.status_changed_at).not_to eq(original_time)
      end
    end
  end
end
