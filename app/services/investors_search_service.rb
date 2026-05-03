class InvestorsSearchService
  MAX_LIMIT = 100
  DEFAULT_LIMIT = 10

  def initialize(params, base_scope: nil)
    @params = params
    @base_scope_override = base_scope
  end

  def call
    investors = filtered_and_sorted_scope
    total = investors.count
    paginated = investors.offset((page - 1) * limit).limit(limit).to_a
    total_pages = (total.to_f / limit).ceil

    {
      total: total,
      page: page,
      totalPages: total_pages,
      limit: limit,
      hasNext: page < total_pages,
      hasPrev: page > 1,
      data: paginated.map { |investor| InvestorsSerializer.list_item(investor) }
    }
  end

  def filtered_and_sorted_scope
    investors = base_scope
    investors = apply_name_filter(investors)
    investors.order(Arel.sql(order_sql))
  end

  private

  def page
    @page ||= [@params[:page].to_i, 1].max
  end

  def limit
    @limit ||= begin
      requested = @params[:limit].to_i
      requested = DEFAULT_LIMIT unless requested.positive?
      [requested, MAX_LIMIT].min
    end
  end

  def base_scope
    @base_scope_override || Investor.includes(
      location: { country: :region },
      investment_vehicles: {
        investment_vehicle_investment_strategies: {
          investment_strategy: [
            { investment_strategy_region_focuses: :region },
            { investment_strategy_country_focuses: :country }
          ]
        }
      }
    )
  end

  def apply_name_filter(scope)
    name_filter = @params.dig(:columnFilter, :name).to_s.strip
    return scope if name_filter.blank?

    term = "%#{name_filter.downcase}%"
    scope
      .left_outer_joins(:investment_vehicles)
      .left_outer_joins(investment_vehicles: :investment_vehicle_investment_strategies)
      .left_outer_joins(
        investment_vehicles: {
          investment_vehicle_investment_strategies: :investment_strategy
        }
      )
      .where(
        "LOWER(public.investors.name) LIKE :term OR LOWER(public.investment_vehicles.name) LIKE :term OR LOWER(public.investment_strategies.name) LIKE :term",
        term: term
      )
      .distinct
  end

  def order_sql
    sort_field = @params.dig(:sort, 0, :field).to_s
    sort_direction = @params.dig(:sort, 0, :direction).to_s.downcase == "desc" ? "DESC" : "ASC"
    case sort_field
    when "updatedAtUtc" then "public.investors.updated_at_utc #{sort_direction} NULLS LAST"
    else "public.investors.name #{sort_direction}, public.investors.id ASC"
    end
  end
end
