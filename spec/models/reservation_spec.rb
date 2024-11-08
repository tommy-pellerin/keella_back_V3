# require 'rails_helper'

# RSpec.describe Reservation, type: :model do
#   # Validations
#   describe 'validations' do
#     it { should validate_presence_of(:quantity) }
#     it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
#   end

#   # Associations
#   describe 'associations' do
#     it { should belong_to(:user) }
#     it { should belong_to(:workout) }
#   end

#   # Méthode (exemple)
#   describe '#total_price' do
#     it 'calculates the total price based on quantity and workout price' do
#       workout = Workout.new(price_per_session: 20)
#       reservation = Reservation.new(workout: workout, quantity: 3)
#       expect(reservation.total_price).to eq(60) # 3 * 20
#     end
#   end
# end
