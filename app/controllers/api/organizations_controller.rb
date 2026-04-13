module Api
  class OrganizationsController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES

    before_action only: [:index] do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def index
      items = OrganizationProfile.order(:company_name).map do |org|
        {
          value: org.id,
          text: org.company_name
        }
      end

      render json: { items: items }, status: :ok
    end
  end
end
