class InvestorCurrency < ApplicationRecord

  acts_as_paranoid

  belongs_to :currency
  belongs_to :investor

end
