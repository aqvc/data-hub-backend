class InvestmentVehicleInvestmentStrategy < ApplicationRecord

  self.table_name = "public.investment_vehicles_investment_strategies"

  belongs_to :investment_vehicle
  belongs_to :investment_strategy

end
