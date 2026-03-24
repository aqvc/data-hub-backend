class City < ApplicationRecord

  self.table_name = "public.cities"

  belongs_to :country
  has_many :city_ideal_investor_profiles, class_name: "CityIdealInvestorProfile", foreign_key: :investor_headquarters_id

end
