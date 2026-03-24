class Location < ApplicationRecord

  self.table_name = "public.locations"

  belongs_to :country
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :investment_entities, class_name: "InvestmentEntity", foreign_key: :headquarters_address_id
  has_many :investment_entities, class_name: "InvestmentEntity", foreign_key: :location_id
  has_many :investment_vehicles, class_name: "InvestmentVehicle", foreign_key: :marketing_geographies_id
  has_many :investment_vehicles, class_name: "InvestmentVehicle", foreign_key: :location_id
  has_many :investor_contacts
  has_many :investors

  enum :location_type, {
    primary: "primary",
    secondary: "secondary"
  }

end
