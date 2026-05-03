class DatabaseInsightsDistributionsService
  def call
    counts = aggregate_counts
    {
      by_type: to_chart_data(counts[:by_type]),
      by_sector: to_chart_data(counts[:by_sector]),
      by_stage: to_chart_data(counts[:by_stage]),
      by_country: to_chart_data(counts[:by_country]),
      by_region: to_chart_data(counts[:by_region]),
      by_maturity: to_chart_data(counts[:by_maturity])
    }
  rescue StandardError => e
    ErrorLogger.error("DatabaseInsightsDistributionsService#call: #{e.class} - #{e.message}")
    raise e
  end

  private

  def aggregate_counts
    counts = {
      by_type: Hash.new(0),
      by_sector: Hash.new(0),
      by_stage: Hash.new(0),
      by_country: Hash.new(0),
      by_region: Hash.new(0),
      by_maturity: Hash.new(0)
    }

    grouped_strategies.each_value do |list|
      first = list.first
      investor_type = first&.investor&.type
      counts[:by_type][investor_type.to_s] += 1 if investor_type.present?

      list.flat_map { |s| Array(s.sector_investment_focus) }.uniq.each { |v| counts[:by_sector][v.to_s] += 1 if v.present? }
      list.flat_map { |s| Array(s.stage_focus) }.uniq.each { |v| counts[:by_stage][v.to_s] += 1 if v.present? }
      list.flat_map { |s| Array(s.maturity_focus) }.uniq.each { |v| counts[:by_maturity][v.to_s] += 1 if v.present? }
      list.flat_map { |s| s.investment_strategy_country_focuses.map { |f| f.country&.name } }.compact.uniq.each { |v| counts[:by_country][v] += 1 }
      list.flat_map { |s| s.investment_strategy_region_focuses.map { |f| f.region&.name } }.compact.uniq.each { |v| counts[:by_region][v] += 1 }
    end

    counts
  end

  def grouped_strategies
    InvestmentStrategy
      .where.not(investor_id: nil)
      .includes(
        :investor,
        investment_strategy_region_focuses: :region,
        investment_strategy_country_focuses: :country
      )
      .to_a
      .group_by(&:investor_id)
  end

  def to_chart_data(hash)
    hash.map { |label, count| { label: label, count: count } }
        .sort_by { |point| -point[:count] }
  end
end
