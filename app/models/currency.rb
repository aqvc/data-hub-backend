class Currency < ApplicationRecord

  has_many :countries
  has_many :investment_vehicles
  has_many :investor_currencies

end
