class InvestorsSerializer
  DEFAULT_EXPORT_COLUMNS = %w[name websiteUrl investorType headquarter updatedAtUtc].freeze

  def self.list_item(investor)
    {
      id: investor.id,
      name: investor.name,
      websiteUrl: investor.website_url,
      type: investor.type,
      updatedAtUtc: investor.updated_at_utc,
      qualified: investor.qualified,
      offices: investor.offices,
      location: location(investor.location),
      investmentVehicles: investor.investment_vehicles.map { |v| { id: v.id, name: v.name } },
      investmentStrategies: strategies_for(investor).map { |s| strategy(s) }
    }
  end

  def self.detail(investor)
    payload = camelize_attrs(investor)
    payload["location"] = location(investor.location)
    payload["investmentVehicles"] = investor.investment_vehicles.map { |v| camelize_attrs(v) }
    payload["investmentStrategies"] = investor.investment_strategies.map { |s| camelize_attrs(s) }
    payload["contactsCount"] = investor.investor_contacts.count
    payload["investmentEntitiesCount"] = InvestmentEntity
                                         .joins(:investment_vehicle)
                                         .where("\"public\".\"investment_vehicles\".\"investor_id\" = ?", investor.id)
                                         .count
    payload
  end

  def self.camelize_attrs(record)
    record.attributes.each_with_object({}) do |(k, v), memo|
      memo[k.to_s.camelize(:lower)] = v
    end
  end

  def self.location(location)
    return nil if location.nil?

    {
      id: location.id,
      city: location.city,
      country: {
        id: location.country&.id,
        name: location.country&.name,
        region: {
          id: location.country&.region&.id,
          name: location.country&.region&.name
        }
      }
    }
  end

  def self.strategy(strategy)
    {
      id: strategy.id,
      name: strategy.name,
      assetClassFocus: strategy.asset_class_focus || [],
      sectorInvestmentFocus: strategy.sector_investment_focus || [],
      maturityFocus: strategy.maturity_focus || [],
      stageFocus: strategy.stage_focus || [],
      investorTypeFocus: strategy.investor_type_focus || [],
      regionInvestmentFocus: strategy.investment_strategy_region_focuses.map { |rf| rf.region&.name }.compact,
      countryInvestmentFocus: strategy.investment_strategy_country_focuses.map { |cf| cf.country&.name }.compact
    }
  end

  def self.strategies_for(investor)
    investor.investment_vehicles
            .flat_map(&:investment_vehicle_investment_strategies)
            .map(&:investment_strategy)
            .compact
            .uniq(&:id)
  end
end
