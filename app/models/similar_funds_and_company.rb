class SimilarFundsAndCompany < ApplicationRecord

  has_many :similar_fund_and_company_iips, class_name: "SimilarFundAndCompanyIip", foreign_key: :similar_fund_and_company_id

end
