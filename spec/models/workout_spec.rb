# require 'rails_helper'

# RSpec.describe Workout, type: :model do
#   # Validations
#   describe 'validations' do
#     it { should validate_presence_of(:title) }
#     it { should validate_presence_of(:price_per_session) }
#     it { should validate_numericality_of(:price_per_session).is_greater_than(0) }
#   end

#   # Associations
#   describe 'associations' do
#     it { should belong_to(:host).class_name('User') }
#     it { should belong_to(:category) }
#     it { should have_many(:availabilities) }
#     it { should have_many(:reservations) }
#   end

#   # Méthode (exemple)
#   describe '#indoor?' do
#     it 'returns true if workout is indoors' do
#       workout = Workout.new(is_indoor: true)
#       expect(workout.indoor?).to be true
#     end
#   end
# end
