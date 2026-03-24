module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    include GraphqlSupport::AuthHelpers
    include GraphqlSupport::ErrorHelpers
    include GraphqlSupport::PayloadHelpers

    null false

    private

    def persist_proof_points!(proof_points, fallback_relation)
      ProofLedgerPersistenceService.persist_from_payload!(
        proof_points: proof_points,
        current_user_id: current_user_id,
        fallback_relation: fallback_relation
      )
    end
  end
end
