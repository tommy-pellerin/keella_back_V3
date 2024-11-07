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

categories.each do |category|
  Category.create(
    title: category
  )
end

puts '>>> Categories created <<<'

admin = User.create(
  # firstname: 'thisis',
  # lastname: 'admin',
  email: 'na_ru_to619@hotmail.fr',
  password: 'admin123',
  # isAdmin: true,
)
admin.confirmed_at = Time.now
admin.save
puts '>>> Admin created and confirmed <<<'

ActionMailer::Base.perform_deliveries = false

10.times do
  user = User.create(
    email: Faker::Internet.email,
    password: 'azerty123',
  )

  # Bypass email confirmation by setting confirmed_at
  user.confirmed_at = Time.now
  user.save
end

puts '>>> Users created and confirmed <<<'

workouts = []
20.times do
  # Generate random city and zip code using Faker
  city = Faker::Address.city
  zip_code = Faker::Address.zip_code

  # Pick a random category from the Category model
  category = Category.all.sample

  # Generate random equipment list (you can add more sample equipment if you like)
  equipments = [ "Tapis de yoga", "Haltères", "Corde à sauter", "Vélo", "Kettlebells" ].sample(3).join(", ")

  # Generate a random address (could be a placeholder if not stored in your database)
  address = Faker::Address.street_address

  # Create the workout entry
  workouts << Workout.create(
    title: "Séance de #{category.title} à #{city}",
    description: Faker::Lorem.paragraph,
    equipments: equipments,
    address: address,
    city: city,
    zip_code: zip_code,
    price_per_session: rand(10..50),  # Random price between 10 and 50
    max_participants: rand(1..15),    # Random number of participants between 1 and 15
    host: User.all.sample,            # Random user as host
    category: category,               # The category for the workout
    is_indoor: [ true, false ].sample,  # Random indoor/outdoor
    host_present: [ true, false ].sample  # Random host presence
  )
end

puts '>>> Workouts created <<<'

availabilities = []
workouts.each do |workout|
  5.times do
    # Generate a random start_date within the next 10 days, no morning constraint
    start_date = Faker::Time.forward(days: rand(1..10)) # No period restriction, so it can generate day or night times

    # Generate a random time between 6 AM and midnight
    start_time = Faker::Time.between_dates(from: Date.today, to: Date.today + 1, period: :evening).to_time
    start_time = start_time.change({ hour: rand(6..23), min: rand(0..3)*15 }) # Ensuring time is between 6 AM and midnight, in 15 minute intervals

    # Duration in 15-minute intervals
    duration = [ 30, 45, 60, 75, 90, 105, 120 ].sample # Duration in 15-minute intervals (30, 45, 60, etc.)

    # Calculate end_time by adding the duration to start_time, but store it in end_date (as a time)
    end_time = (start_time + duration.minutes).strftime('%H:%M') # Adding duration to start_time

    availabilities << {
      workout_id: workout.id,
      start_date: start_date,
      start_time: start_time,
      end_date: end_time,
      duration: duration,
      is_booked: false
    }
  end
end

# Bulk insert availabilities
Availability.create!(availabilities)
puts ">>> availabilities created <<<"

50.times do
  user = User.all.sample
  quantity = rand(1..2)
  workout = Workout.all.sample
  while user == workout.host
    workout = Workout.all.sample
  end
  Reservation.create(
    user: user,
    workout: workout,
    quantity: quantity,
    total: workout.price_per_session * quantity,
  )
end
puts '>>> Reservations created <<<'

puts '>>> Greate job ! ALL DONE <<<'
ActionMailer::Base.perform_deliveries = true
