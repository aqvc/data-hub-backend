module Api
  class InvestmentEntitiesController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = %w[Admin DataManager AccountManager].freeze

    before_action do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def index
      entities = InvestmentEntity
                 .joins(:investment_vehicle)
                 .where("\"public\".\"investment_vehicles\".\"investor_id\" = ?", params[:investor_id])
                 .order(created_at_utc: :desc, id: :asc)
      render json: { data: entities.map { |e| serialize_record(e) } }, status: :ok
    end

    def create
      vehicle_id = params[:investmentVehicleId]
      if vehicle_id.blank?
        investor = Investor.find_by(id: params[:investorId])
        if investor.nil?
          return render_not_found("Investors.NotFound", params[:investorId])
        end

        vehicle_id = investor.investment_vehicles.order(created_at_utc: :desc).pick(:id)
      end

      vehicle = InvestmentVehicle.find_by(id: vehicle_id)
      return render_not_found("InvestmentVehicles.NotFound", vehicle_id) if vehicle.nil?

      entity = InvestmentEntity.new(
        investment_vehicle_id: vehicle.id,
        created_by_id: current_user_id,
        created_at_utc: Time.now.utc
      )

      if entity.save
        render json: { id: entity.id }, status: :ok
      else
        render_problem(
          code: "InvestmentEntities.CreateFailed",
          detail: entity.errors.full_messages.join(", "),
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end
    end

    def update
      entity = InvestmentEntity.find_by(id: params[:id])
      return render_not_found("InvestmentEntities.NotFound", params[:id]) if entity.nil?

      attrs = extract_model_attributes(:investmentEntity)
      assign_filtered_attributes(entity, attrs)
      entity.updated_by_id = current_user_id if entity.respond_to?(:updated_by_id=)
      entity.updated_at_utc = Time.now.utc if entity.respond_to?(:updated_at_utc=)
      ActiveRecord::Base.transaction do
        entity.save!
        ProofLedgerPersistenceService.persist_from_payload!(
          proof_points: params[:proofPoints],
          current_user_id: current_user_id,
          fallback_relation: { "investment_entity_id" => entity.id }
        )
      end
      head :ok
    rescue ActiveRecord::RecordInvalid => e
      render_problem(
        code: "InvestmentEntities.UpdateFailed",
        detail: e.record.errors.full_messages.join(", "),
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
        status: 400
      )
    end

    def destroy
      entity = InvestmentEntity.find_by(id: params[:id])
      return render_not_found("InvestmentEntities.NotFound", params[:id]) if entity.nil?

      entity.destroy
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
