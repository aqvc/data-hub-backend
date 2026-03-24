module GraphqlApi
  class AnalyticsDistributionsService
    include GraphqlSupport::PayloadHelpers

    def call
      strategies = InvestmentStrategy
                   .where.not(investor_id: nil)
                   .includes(
                     :investor,
                     investment_strategy_region_focuses: :region,
                     investment_strategy_country_focuses: :country
                   )
                   .to_a

      grouped = strategies.group_by(&:investor_id)

      by_type = Hash.new(0)
      by_sector = Hash.new(0)
      by_stage = Hash.new(0)
      by_country = Hash.new(0)
      by_region = Hash.new(0)
      by_maturity = Hash.new(0)

      grouped.each_value do |list|
        first = list.first
        investor_type = first&.investor&.type
        by_type[investor_type.to_s] += 1 if investor_type.present?

        list.flat_map { |strategy| Array(strategy.sector_investment_focus) }.uniq.each { |value| by_sector[value.to_s] += 1 if value.present? }
        list.flat_map { |strategy| Array(strategy.stage_focus) }.uniq.each { |value| by_stage[value.to_s] += 1 if value.present? }
        list.flat_map { |strategy| Array(strategy.maturity_focus) }.uniq.each { |value| by_maturity[value.to_s] += 1 if value.present? }
        list.flat_map { |strategy| strategy.investment_strategy_country_focuses.map { |focus| focus.country&.name } }.compact.uniq.each { |value| by_country[value] += 1 }
        list.flat_map { |strategy| strategy.investment_strategy_region_focuses.map { |focus| focus.region&.name } }.compact.uniq.each { |value| by_region[value] += 1 }
      end

      deep_camelize(
        by_type: to_chart_data(by_type),
        by_sector: to_chart_data(by_sector),
        by_stage: to_chart_data(by_stage),
        by_country: to_chart_data(by_country),
        by_region: to_chart_data(by_region),
        by_maturity: to_chart_data(by_maturity)
      )
    end

    private

    def to_chart_data(hash)
      hash.map { |label, count| { label: label, count: count } }.sort_by { |point| -point[:count] }
    end
  end
end
