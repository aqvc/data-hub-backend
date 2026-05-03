module Api
  class AnalyticsController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES

    before_action do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def database_insights_overview
      render json: deep_camelize(DatabaseInsightsOverviewService.new.call), status: :ok
    end

    def database_insights_distributions
      render json: deep_camelize(DatabaseInsightsDistributionsService.new.call), status: :ok
    end

    def team
      render json: deep_camelize(TeamPerformanceService.new(ALL_ROLES).call), status: :ok
    end
  end
end
