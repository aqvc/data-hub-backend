module Api
  class InvestorContactsController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = %w[Admin DataManager AccountManager].freeze

    before_action do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def index
      contacts = InvestorContact.where(investor_id: params[:investor_id]).order(created_at_utc: :desc, id: :asc)
      render json: { data: contacts.map { |c| serialize_record(c) } }, status: :ok
    end

    def create
      investor = Investor.find_by(id: params[:investorId])
      return render_not_found("Investors.NotFound", params[:investorId]) if investor.nil?

      contact = InvestorContact.new(
        investor_id: investor.id,
        created_by_id: current_user_id,
        created_at_utc: Time.now.utc
      )

      if contact.save
        render json: { id: contact.id }, status: :ok
      else
        render_problem(
          code: "InvestorContacts.CreateFailed",
          detail: contact.errors.full_messages.join(", "),
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end
    end

    def update
      contact = InvestorContact.find_by(id: params[:id])
      return render_not_found("InvestorContacts.NotFound", params[:id]) if contact.nil?

      attrs = extract_model_attributes(:investorContact)
      assign_filtered_attributes(contact, attrs)
      contact.updated_by_id = current_user_id if contact.respond_to?(:updated_by_id=)
      contact.updated_at_utc = Time.now.utc if contact.respond_to?(:updated_at_utc=)
      ActiveRecord::Base.transaction do
        contact.save!
        ProofLedgerPersistenceService.persist_from_payload!(
          proof_points: params[:proofPoints],
          current_user_id: current_user_id,
          fallback_relation: { "investor_contact_id" => contact.id }
        )
      end
      head :ok
    rescue ActiveRecord::RecordInvalid => e
      render_problem(
        code: "InvestorContacts.UpdateFailed",
        detail: e.record.errors.full_messages.join(", "),
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
        status: 400
      )
    end

    def destroy
      contact = InvestorContact.find_by(id: params[:id])
      return render_not_found("InvestorContacts.NotFound", params[:id]) if contact.nil?

      contact.destroy
      head :ok
    end

    private

    def current_user_id
      current_user_claims[JwtTokenService::NAME_ID_CLAIM]
    end

    def render_not_found(code, id)
      render_problem(
        code: code,
        detail: "The resource with the Id = '#{id}' was not found",
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.4",
        status: 404
      )
    end
  end
end
