class UserMailer < ApplicationMailer
  default from: "noreply@votreapp.com"

  def email_update_confirmation(user)
    @user = user
    mail(to: @user.email, subject: "Votre adresse email a été mise à jour avec succès")
  end
end
