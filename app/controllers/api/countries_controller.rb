module Api
  class CountriesController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES

    before_action only: [:index] do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def index
      scope = Country.order(:name)
      region_ids = Array(params[:regionIds]).compact_blank
      scope = scope.where(region_id: region_ids) if region_ids.any?

      data = scope.map do |country|
        {
          id: country.id,
          regionId: country.region_id,
          name: country.name,
          isoCode: country.iso_code,
          iso3Code: country.iso3code,
          callingCode: country.calling_code,
          currencyId: country.currency_id,
          createdAtUtc: country.created_at_utc,
          updatedAtUtc: country.updated_at_utc
        }
      end

      render json: { data: data }, status: :ok
    end
  end
end
