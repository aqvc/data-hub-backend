module Api
  class IdealInvestorProfilesController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES

    before_action only: [:index] do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def index
      scope = IdealInvestorProfile.order(:name)
      organization_ids = Array(params[:organizationIds]).compact_blank
      scope = scope.where(organization_profile_id: organization_ids) if organization_ids.any?

      data = scope.map do |iip|
        {
          id: iip.id,
          organizationProfileId: iip.organization_profile_id,
          name: iip.name,
          description: iip.description,
          fundProfileId: iip.fund_profile_id,
          briefing: iip.briefing,
          minCheckSize: iip.min_check_size,
          maxCheckSize: iip.max_check_size,
          thematicKeywords: iip.thematic_keywords || [],
          assetClass: iip.asset_class || [],
          sectorFocus: iip.sector_focus || [],
          investorType: iip.investor_type || [],
          maturityFocus: iip.maturity_focus || [],
          stageFocus: iip.stage_focus || [],
          strategyFocus: iip.strategy_focus || [],
          regionHeadquarterId: iip.region_headquarter_id,
          countryHeadquarterId: iip.country_headquarter_id,
          cityHeadquarter: iip.city_headquarter,
          createdById: iip.created_by_id,
          updatedById: iip.updated_by_id,
          createdAtUtc: iip.created_at_utc,
          updatedAtUtc: iip.updated_at_utc
        }
      end

      render json: { data: data }, status: :ok
    end
  end
end
