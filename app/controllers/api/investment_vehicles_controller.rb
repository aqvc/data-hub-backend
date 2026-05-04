module Api
  class InvestmentVehiclesController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES

    before_action do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def show
      vehicle = InvestmentVehicle.find_by(id: params[:id])
      return render_not_found("InvestmentVehicles.NotFound", params[:id]) if vehicle.nil?

      render json: serialize_record(vehicle), status: :ok
    end

    def create
      investor_id = params[:investorId]
      investor = Investor.find_by(id: investor_id)
      return render_not_found("Investors.NotFound", investor_id) if investor.nil?

      vehicle = InvestmentVehicle.new(
        investor_id: investor.id,
        name: params[:name].presence || "",
        created_by_id: current_user_id,
        created_at_utc: Time.now.utc
      )

      if vehicle.save
        render json: { id: vehicle.id }, status: :ok
      else
        render_problem(
          code: "InvestmentVehicles.CreateFailed",
          detail: vehicle.errors.full_messages.join(", "),
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end
    end

    def update
      vehicle = InvestmentVehicle.find_by(id: params[:id])
      return render_not_found("InvestmentVehicles.NotFound", params[:id]) if vehicle.nil?

      attrs = extract_model_attributes(:investmentVehicle)
      assign_filtered_attributes(vehicle, attrs)
      vehicle.updated_by_id = current_user_id if vehicle.respond_to?(:updated_by_id=)
      vehicle.updated_at_utc = Time.now.utc if vehicle.respond_to?(:updated_at_utc=)
      ActiveRecord::Base.transaction do
        vehicle.save!
        ProofLedgerPersistenceService.new(
          proof_points: params[:proofPoints],
          current_user_id: current_user_id,
          fallback_relation: { "investment_vehicle_id" => vehicle.id }
        ).call
      end
      head :ok
    rescue ActiveRecord::RecordInvalid => e
      render_problem(
        code: "InvestmentVehicles.UpdateFailed",
        detail: e.record.errors.full_messages.join(", "),
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
        status: 400
      )
    end

    private

    def current_user_id
      current_user_claims[JwtTokenService::NAME_ID_CLAIM]&.to_i
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
