module Api
  class CitiesController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES

    before_action do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def by_country
      cities = City.where(country_id: params[:id]).order(:name)
      render json: { data: cities.map { |city| serialize_record(city) } }, status: :ok
    end
  end
end
