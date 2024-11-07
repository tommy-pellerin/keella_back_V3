# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


require 'faker'
Faker::Config.locale = 'fr'

# Supprimer toutes les données existantes
def reset_db
  Category.destroy_all
  Reservation.destroy_all
  Availability.destroy_all
  Workout.destroy_all
  User.destroy_all

  # reset table sequence
  ActiveRecord::Base.connection.tables.each do |t|
    # postgreSql
    ActiveRecord::Base.connection.reset_pk_sequence!(t)
    # SQLite
    # ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = '#{t}'")
  end

  puts('>>> drop and reset all tables <<<')
end
reset_db

# Méthode pour créer les catégories
def create_categories
  categories = [
    # Activités individuelles ou en groupe, praticables à la maison
    'Yoga', 'Pilates', 'Fitness', 'HIIT', 'Musculation',
    'Zumba', 'Tabata', 'Boxe', 'Méditation Guidée', 'Mobilité',
    'Circuit Training', 'Gym Douce', 'Taï Chi',

    # Activités partageables, idéal pour des groupes ou des duos
    'Ping-Pong', 'Badminton', 'Air Hockey', 'Mini-Golf',
    'Fléchettes', 'Bowling de Salon', 'Baby-foot', 'Pétanque',
    'Squash', 'Volley-ball', 'Tennis'
  ]

  created_count = 0
  categories.each do |category|
    category_record = Category.create(title: category)
    if category_record.persisted?
      created_count += 1
    else
      puts "Erreur lors de la création de la catégorie '#{category}': #{category_record.errors.full_messages.join(", ")}"
    end
  end

  if created_count > 0
    puts ">>> #{created_count} categories successfully created <<<"
  end
end

# Appel de la méthode de création des catégories
create_categories

# Méthode pour créer un administrateur avec gestion des erreurs
def create_admin(email, password)
  admin = User.new(email: email, password: password)

  if admin.save
    admin.confirmed_at = Time.now
    admin.save
    puts '>>> Admin created and confirmed <<<'
  else
    puts "Erreur lors de la création de l'admin : #{admin.errors.full_messages.join(", ")}"
  end

  admin
end

# Appel de la méthode de création de l'admin
create_admin('na_ru_to619@hotmail.fr', 'admin123')

ActionMailer::Base.perform_deliveries = false

# Création des utilisateurs
def create_users
  created_count = 0
  10.times do
    user = User.create(
      email: Faker::Internet.email,
      password: 'azerty123'
    )
    user.confirmed_at = Time.now
    user.save

    if user.persisted?
      created_count += 1
    else
      puts "Erreur lors de la création de l'utilisateur '#{user.email}': #{user.errors.full_messages.join(", ")}"
    end
  end

  if created_count > 0
    puts ">>> #{created_count} users successfully created <<<"
  end
end

# Appel de la méthode pour créer les utilisateurs
create_users

# Méthode pour générer un workout valide
def generate_workout
  city = Faker::Address.city
  zip_code = Faker::Address.zip_code

  # Sélection d'une catégorie aléatoire
  category = Category.all.sample

  # Sélection aléatoire des équipements
  equipments = [ "Tapis de yoga", "Haltères", "Corde à sauter", "Vélo", "Kettlebells" ].sample(3).join(", ")

  # Générer une adresse aléatoire
  address = Faker::Address.street_address

  host = User.all.sample

  # Vérification de la validité de la catégorie et du host
  return nil unless category && host

  # Création du workout et gestion des erreurs
  workout = Workout.create(
    title: "Séance de #{category.title} à #{city}",
    description: Faker::Lorem.paragraph,
    equipments: equipments,
    address: address,
    city: city,
    zip_code: zip_code,
    price_per_session: rand(10..50),
    max_participants: rand(1..15),
    host: host,
    category: category,
    is_indoor: [ true, false ].sample,
    host_present: [ true, false ].sample
  )

  # Vérification de la validité du workout créé
  if workout.persisted?
    workout
  else
    puts "Erreur lors de la création du workout : #{workout.errors.full_messages.join(", ")}"
    nil
  end
end

# Méthode pour créer des créneaux de disponibilité récurrents pour un workout
def create_availabilities_for_workout(workout)
  availabilities = []

  # Premier créneau : tous les jours à 12h pendant 1 semaine
  start_time_1 = Time.now.change(hour: 12, min: 0)
  duration_1 = 60.minutes # 1h
  recurrence_days_1 = 7   # 1 semaine

  recurrence_days_1.times do |day_offset|
    start_date = start_time_1 + day_offset.days
    end_date = start_date + duration_1

    availabilities << {
      workout_id: workout.id,
      start_date: start_date.to_date,
      start_time: start_date,
      end_date: end_date,
      duration: duration_1 / 60, # Convertir en minutes
      is_booked: false
    }
  end

  # Deuxième créneau : tous les jours à 19h pendant 1 mois
  start_time_2 = Time.now.change(hour: 19, min: 0)
  duration_2 = 60.minutes # 1h
  recurrence_days_2 = 30  # 1 mois

  recurrence_days_2.times do |day_offset|
    start_date = start_time_2 + day_offset.days
    end_date = start_date + duration_2

    availabilities << {
      workout_id: workout.id,
      start_date: start_date.to_date,
      start_time: start_date,
      end_date: end_date,
      duration: duration_2 / 60, # Convertir en minutes
      is_booked: false
    }
  end

  # Création de toutes les disponibilités en une seule transaction
  Availability.create!(availabilities) unless availabilities.empty?

  puts "Créneaux de disponibilité créés pour le workout #{workout.title} : #{availabilities.count} créneaux"
end

# Méthode principale pour créer des workouts avec créneaux
def create_workouts_with_availabilities
  valid_workouts = 0
  invalid_workouts = 0

  20.times do
    workout = generate_workout
    if workout
      valid_workouts += 1
      create_availabilities_for_workout(workout)
    else
      invalid_workouts += 1
    end
  end

  puts ">>> #{valid_workouts} workouts créés avec succès avec leurs créneaux <<<"
  puts ">>> #{invalid_workouts} workouts ont échoué <<<"
end

# Appel de la méthode principale
create_workouts_with_availabilities

# Création des réservations
def create_reservations
  created_count = 0
  50.times do
    user = User.all.sample
    quantity = rand(1..2)
    workout = Workout.all.sample

    # S'assurer que l'utilisateur n'est pas l'hôte de la séance
    while user == workout.host
      workout = Workout.all.sample
    end

    reservation = Reservation.new(
      user: user,
      workout: workout,
      quantity: quantity,
      total: workout.price_per_session * quantity
    )

    if reservation.save
      created_count += 1
    else
      puts "Erreur lors de la création de la réservation pour User '#{user.email}' et Workout '#{workout.title}': #{reservation.errors.full_messages.join(", ")}"
    end
  end

  if created_count > 0
    puts ">>> #{created_count} reservations successfully created <<<"
  end
end

# Appel de la méthode pour créer les réservations
create_reservations

puts '>>> Greate job ! ALL DONE <<<'
ActionMailer::Base.perform_deliveries = true
