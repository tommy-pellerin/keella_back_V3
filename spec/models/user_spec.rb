require 'rails_helper'

RSpec.describe User, type: :model do
  # Définir une instance de User avec `let`
  let(:user) { create(:user) } # crée un User avec les valeurs par défaut de la factory

  # Tests de validation
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid # vérifie que l'instance est valide
    end

    context 'when email is missing' do
      before { user.email = nil } # le code ici est exécuté avant chaque test de ce contexte

      it 'is not valid without an email' do
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank") # test d’erreur de validation
      end
    end

    context 'when first_name or last_name is missing' do
      it 'is not valid without a first_name' do
        user.first_name = nil
        expect(user).not_to be_valid
        expect(user.errors[:first_name]).to include("can't be blank")
      end

      it 'is not valid without a last_name' do
        user.last_name = nil
        expect(user).not_to be_valid
        expect(user.errors[:last_name]).to include("can't be blank")
      end
    end

    context 'when email is not unique' do
      it 'is not valid with a duplicate email' do
        duplicate_user = build(:user, email: user.email) # Construit un User sans le sauvegarder
        expect(duplicate_user).not_to be_valid           # Vérifie qu'il est invalide
        # expect(duplicate_user.errors[:email]).to include('has already been taken')
      end
    end

      # Validation de l'âge minimum (18 ans)
    context 'when birthday is invalid' do
      it 'rejects users younger than 18' do
        user.birthday = 17.years.ago + 1.day
        expect(user).not_to be_valid
        expect(user.errors[:birthday]).to include("You must be at least 18 years old")
      end

      it 'accepts users who are exactly 18' do
        user.birthday = 18.years.ago
        expect(user).to be_valid
      end
    end

    context 'when phone number is valid' do
      valid_numbers = [
        "0601020304",           # Format compact
        "06 01 02 03 04",       # Espaces
        "06.01.02.03.04",       # Points
        "06-01-02-03-04",       # Tirets
        "+33 6 01 02 03 04",    # International avec espaces
        "+33.6.01.02.03.04",    # International avec points
        "+33-6-01-02-03-04",    # International avec tirets
        "0033 6 01 02 03 04",   # International compact
        "0033.6.01.02.03.04",   # International avec points
        "0033-6-01-02-03-04"    # International avec tirets
      ]

      it 'is valid with valid phone numbers' do
        valid_numbers.each do |valid_number|
          user.phone = valid_number
          expect(user).to be_valid, "Expected '#{valid_number}' to be valid"
        end
      end
    end

    context 'when phone number is invalid' do
      invalid_numbers = [
        "123456",              # Trop court
        "060102030",           # Pas assez de chiffres
        "06:01:02:03:04",      # Mauvais séparateur
        "0034 6 01 02 03 04"   # Mauvais indicatif international
      ]

      it 'is not valid with invalid phone numbers' do
        invalid_numbers.each do |invalid_number|
          user.phone = invalid_number
          expect(user).not_to be_valid, "Expected '#{invalid_number}' to be invalid"
        end
      end
    end

  end

  # Tests d'association
  describe 'associations' do
    it { should belong_to(:city) }
    context 'when user is host' do
      it { should have_many(:hosted_workouts) }
    end
    context 'when user is participant' do
      it { should have_many(:booked_workouts) }
      it { should have_many(:reservations) }
    end
  end

  # Tests des callbacks
  describe 'callbacks' do
    describe 'after_confirmation callback' do
      let(:unconfirmed_user) { create(:user, confirmed_at: nil) }

      it 'sends a confirmation email after the user confirms their account' do
        # On "espionne" le mailer pour vérifier qu'il est appelé
        allow(UserMailer).to receive_message_chain(:welcome_email, :deliver_now)

        # Confirme l'utilisateur, ce qui devrait appeler welcome_send et donc envoyer l'email
        unconfirmed_user.confirm

        # Vérifie que welcome_email a bien été appelé avec unconfirmed_user
        expect(UserMailer).to have_received(:welcome_email).with(unconfirmed_user)
      end
    end
  end

  # Tests de méthodes
  describe '#confirmed?' do
    it 'returns true if the user is confirmed' do
      user = User.new(email: 'test@example.com', password: 'password', confirmed_at: Time.now)
      expect(user.confirmed?).to be true
    end
  end
end
