module Types
  class MutationType < Types::BaseObject
    field :login, mutation: Mutations::Login
    field :logout, mutation: Mutations::Logout
    field :create_account_manager, mutation: Mutations::CreateAccountManager
    field :send_invitation, mutation: Mutations::SendInvitation
    field :accept_invitation, mutation: Mutations::AcceptInvitation
    field :resend_invitation, mutation: Mutations::ResendInvitation
    field :update_user, mutation: Mutations::UpdateUser
    field :update_profile, mutation: Mutations::UpdateProfile
    field :delete_user, mutation: Mutations::DeleteUser
    field :create_investor, mutation: Mutations::CreateInvestor
    field :update_investor, mutation: Mutations::UpdateInvestor
    field :delete_investor, mutation: Mutations::DeleteInvestor
    field :qualify_investor, mutation: Mutations::QualifyInvestor
    field :create_investment_vehicle, mutation: Mutations::CreateInvestmentVehicle
    field :update_investment_vehicle, mutation: Mutations::UpdateInvestmentVehicle
    field :create_investment_strategy, mutation: Mutations::CreateInvestmentStrategy
    field :update_investment_strategy, mutation: Mutations::UpdateInvestmentStrategy
    field :create_investor_contact, mutation: Mutations::CreateInvestorContact
    field :update_investor_contact, mutation: Mutations::UpdateInvestorContact
    field :delete_investor_contact, mutation: Mutations::DeleteInvestorContact
    field :create_investment_entity, mutation: Mutations::CreateInvestmentEntity
    field :update_investment_entity, mutation: Mutations::UpdateInvestmentEntity
    field :delete_investment_entity, mutation: Mutations::DeleteInvestmentEntity
    field :update_proof_ledger, mutation: Mutations::UpdateProofLedger
    field :delete_proof_ledger, mutation: Mutations::DeleteProofLedger
    field :create_proof_ledger_comment, mutation: Mutations::CreateProofLedgerComment
  end
end
