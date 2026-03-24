namespace :db do
  desc "Seed auth users/roles for legacy AQVC schema"
  task seed_auth: :environment do
    load Rails.root.join("db/seeds.rb")
  end
end
