module GraphqlSupport
  module ErrorHelpers
    private

    def raise_execution_error(code:, detail:, status:, type:, errors: nil)
      extensions = {
        code: code,
        detail: detail,
        status: status,
        type: type
      }
      extensions[:errors] = errors if errors.present?

      raise GraphQL::ExecutionError.new(detail, extensions: extensions)
    end

    def raise_not_found(code, id, resource_name = "resource")
      raise_execution_error(
        code: code,
        detail: "The #{resource_name} with the Id = '#{id}' was not found",
        status: 404,
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.4"
      )
    end
  end
end
