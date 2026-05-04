class GraphqlController < ApplicationController
  include JwtAuthentication

  def execute
    result = HubBackendRailsSchema.execute(
      params[:query],
      variables: prepare_variables(params[:variables]),
      operation_name: params[:operationName],
      context: {
        controller: self
      }
    )

    render json: result
  rescue StandardError => e
    ErrorLogger.error("GraphqlController#execute failed: #{e.class} - #{e.message}")
    raise e if Rails.env.development? || Rails.env.test?

    render json: {
      errors: [
        {
          message: "Unexpected error",
          extensions: {
            code: "Graphql.UnexpectedError"
          }
        }
      ]
    }, status: :internal_server_error
  end

  private

  def prepare_variables(variables_param)
    case variables_param
    when String
      variables_param.present? ? JSON.parse(variables_param) : {}
    when Hash, ActionController::Parameters
      variables_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected variables parameter: #{variables_param.class}"
    end
  end
end
