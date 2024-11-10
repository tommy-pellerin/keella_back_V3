require 'rails_helper'

RSpec.describe City, type: :model do
  let(:city) { build(:city) }

  # Validations
  describe 'validations' do
    # Présence des attributs requis
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:zip_code) }     # Le code postal doit être présent
    it { should allow_value('75001').for(:zip_code) } # Validation du format du code postal
    it { should_not allow_value('abcde').for(:zip_code) }  # Test d'un code postal invalide
  end
end
