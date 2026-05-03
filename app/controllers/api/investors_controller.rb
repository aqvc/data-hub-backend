module Api
  class InvestorsController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES
    EXPORT_RECORD_LIMIT = 2_000

    before_action only: [:search, :create, :show, :update, :qualify, :export_by_filters, :export_by_ids] do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def search
      render json: InvestorsSearchService.new(params).call, status: :ok
    end

    def export_by_filters
      csv = InvestorsCsvExportService.new(params: params, mode: :filters).call
      send_data csv, filename: "Investors.csv", type: "text/csv"
    end

    def export_by_ids
      csv = InvestorsCsvExportService.new(params: params, mode: :ids).call
      send_data csv, filename: "Investors.csv", type: "text/csv"
    end

    def create
      return render_unauthorized if current_user_id.blank?

      investor = Investor.new(
        name: "",
        created_by_id: current_user_id,
        created_at_utc: Time.now.utc,
        qualified: false
      )

      if investor.save
        render json: { id: investor.id }, status: :ok
      else
        render_problem(
          code: "Investors.CreateFailed",
          detail: investor.errors.full_messages.join(", "),
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end
    end

    def show
      investor = Investor.includes(:location, :investment_vehicles, :investment_strategies).find_by(id: params[:id])
      return render_not_found if investor.nil?

      render json: InvestorsSerializer.detail(investor), status: :ok
    end

    def update
      investor = Investor.find_by(id: params[:id])
      return render_not_found if investor.nil?

      attrs = extract_model_attributes(:investor)
      assign_filtered_attributes(investor, attrs)
      investor.updated_by_id = current_user_id if investor.respond_to?(:updated_by_id=)
      investor.updated_at_utc = Time.now.utc if investor.respond_to?(:updated_at_utc=)

      ActiveRecord::Base.transaction do
        investor.save!
        ProofLedgerPersistenceService.new(
          proof_points: params[:proofPoints],
          current_user_id: current_user_id,
          fallback_relation: { "investor_id" => investor.id }
        ).call
      end
      head :ok
    rescue ActiveRecord::RecordInvalid => e
      render_problem(
        code: "Investors.UpdateFailed",
        detail: e.record.errors.full_messages.join(", "),
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
        status: 400
      )
    end

    def qualify
      investor = Investor.find_by(id: params[:id])
      return render_not_found if investor.nil?

      investor.qualified = ActiveModel::Type::Boolean.new.cast(params[:qualified])
      investor.updated_by_id = current_user_id if investor.respond_to?(:updated_by_id=)
      investor.updated_at_utc = Time.now.utc if investor.respond_to?(:updated_at_utc=)

      if investor.save
        head :ok
      else
        render_problem(
          code: "Investors.QualifyFailed",
          detail: investor.errors.full_messages.join(", "),
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end
    end

    private

    def current_user_id
      current_user_claims[JwtTokenService::NAME_ID_CLAIM]
    end

    def render_not_found
      render_problem(
        code: "Investors.NotFound",
        detail: "The investor with the Id = '#{params[:id]}' was not found",
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.4",
        status: 404
      )
    end

    def render_unauthorized
      render_problem(
        code: "Users.Unauthorized",
        detail: "You are not authorized to perform this action.",
        type: "https://tools.ietf.org/html/rfc7231#section-6.6.1",
        status: 500
      )
    end
  end
end
