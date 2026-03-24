class CityIdealInvestorProfile < ApplicationRecord

  belongs_to :investor_headquarters, class_name: "City", foreign_key: :investor_headquarters_id
  belongs_to :ideal_investor_profiles, class_name: "IdealInvestorProfile", foreign_key: :ideal_investor_profiles_id

end
