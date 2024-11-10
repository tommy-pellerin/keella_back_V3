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

    context 'when email is not unique' do
      it 'is not valid with a duplicate email' do
        duplicate_user = build(:user, email: user.email) # Construit un User sans le sauvegarder
        expect(duplicate_user).not_to be_valid           # Vérifie qu'il est invalide
        # expect(duplicate_user.errors[:email]).to include('has already been taken')
      end
    end
    # Ajoute d'autres validations spécifiques à User
  end

  # Tests d'association
  describe 'associations' do
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
