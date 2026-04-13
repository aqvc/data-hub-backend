module Api
  class ProofLedgerController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES

    before_action do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def index
      scope = filter_scope(ProofLedger.includes(:created_by, :updated_by))
      return if performed?

      rows = scope.order(created_at_utc: :desc).to_a
      render json: { data: rows.map { |row| serialize_proof_point(row) } }, status: :ok
    end

    def comments
      scope = filter_scope(ProofLedgerComment.includes(:created_by, :updated_by))
      return if performed?

      if params[:fieldId].present?
        scope = scope.where(field_id: params[:fieldId].to_s)
      end

      rows = scope.order(created_at_utc: :asc).to_a
      render json: { data: rows.map { |row| serialize_comment(row) } }, status: :ok
    end

    def create_comment
      relation = single_relation_filter
      if relation.nil?
        return render_problem(
          code: "ProofLedger.NoFilterSpecified",
          detail: "Either InvestorId, InvestmentVehicleId, InvestmentStrategyId, InvestorContactId or InvestmentEntityId must be provided.",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end

      if params[:fieldId].blank? || params[:comment].to_s.strip.blank?
        return render_problem(
          code: "ProofLedger.CommentInvalid",
          detail: "FieldId and Comment are required.",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end

      reply_to_id = params[:proofLedgerCommentReplyToId].presence
      if reply_to_id.present? && !ProofLedgerComment.exists?(id: reply_to_id)
        return render_problem(
          code: "ProofLedgerComments.NotFound",
          detail: "The proof ledger comment with the Id = '#{reply_to_id}' was not found",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.4",
          status: 404
        )
      end

      comment = ProofLedgerComment.new(
        relation.merge(
          proof_ledger_comment_reply_to_id: reply_to_id,
          field_id: params[:fieldId].to_s,
          comment: params[:comment].to_s.strip,
          created_by_id: current_user_id,
          created_at_utc: Time.now.utc
        )
      )

      if comment.save
        render json: { id: comment.id }, status: :ok
      else
        render_problem(
          code: "ProofLedger.CommentCreateFailed",
          detail: comment.errors.full_messages.join(", "),
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end
    end

    private

    def filter_scope(scope)
      relation = single_relation_filter
      if relation.nil?
        render_problem(
          code: "ProofLedger.NoFilterSpecified",
          detail: "No filter was specified for the ProofLedger query.",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
        return scope.none
      end

      scope.where(relation)
    end

    def single_relation_filter
      relation_pairs = [
        [:investor_id, params[:investorId]],
        [:investment_vehicle_id, params[:investmentVehicleId]],
        [:investment_strategy_id, params[:investmentStrategyId]],
        [:investor_contact_id, params[:investorContactId]],
        [:investment_entity_id, params[:investmentEntityId]]
      ].select { |_k, v| v.present? }

      return nil if relation_pairs.empty? || relation_pairs.size > 1

      key, value = relation_pairs.first
      { key => value }
    end

    def current_user_id
      current_user_claims[JwtTokenService::NAME_ID_CLAIM]
    end

    def serialize_proof_point(row)
      payload = serialize_record(row)
      payload["createdBy"] = row.created_by&.user_name
      payload["updatedBy"] = row.updated_by&.user_name
      payload
    end

    def serialize_comment(row)
      payload = serialize_record(row)
      payload["createdBy"] = row.created_by&.user_name
      payload["updatedBy"] = row.updated_by&.user_name
      payload
    end
  end
end
