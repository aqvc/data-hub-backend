class SimilarFundAndCompanyIip < ApplicationRecord

  belongs_to :ideal_investor_profile
  belongs_to :similar_fund_and_company, class_name: "SimilarFundsAndCompany", foreign_key: :similar_fund_and_company_id

end
