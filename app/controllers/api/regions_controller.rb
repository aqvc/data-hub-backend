module Api
  class RegionsController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = %w[Admin DataManager AccountManager].freeze

    before_action only: [:index] do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def index
      data = Region.order(:name).map do |region|
        {
          id: region.id,
          name: region.name,
          code: region.code,
          description: region.description,
          createdAtUtc: region.created_at_utc,
          updatedAtUtc: region.updated_at_utc
        }
      end

      render json: { data: data }, status: :ok
    end
  end
end
