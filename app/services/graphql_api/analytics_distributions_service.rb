module GraphqlApi
  class AnalyticsDistributionsService
    include GraphqlSupport::PayloadHelpers

    def call
      deep_camelize(
        by_type: aggregate_type_distribution,
        by_sector: aggregate_array_distribution("sector_investment_focus"),
        by_stage: aggregate_array_distribution("stage_focus"),
        by_country: aggregate_country_distribution,
        by_region: aggregate_region_distribution,
        by_maturity: aggregate_array_distribution("maturity_focus")
      )
    end

    private

    def aggregate_type_distribution
      sql = <<~SQL
        SELECT i.type AS label, COUNT(DISTINCT s.investor_id) AS count
        FROM public.investment_strategies s
        INNER JOIN public.investors i ON i.id = s.investor_id
        WHERE s.investor_id IS NOT NULL
          AND i.type IS NOT NULL
        GROUP BY i.type
        ORDER BY COUNT(DISTINCT s.investor_id) DESC;
      SQL
      run_chart_query(sql)
    end

    def aggregate_array_distribution(column_name)
      sql = <<~SQL
        SELECT value AS label, COUNT(DISTINCT investor_id) AS count
        FROM (
          SELECT s.investor_id, unnest(COALESCE(s.#{column_name}::text[], ARRAY[]::text[])) AS value
          FROM public.investment_strategies s
          WHERE s.investor_id IS NOT NULL
        ) grouped
        WHERE value IS NOT NULL
          AND value <> ''
        GROUP BY value
        ORDER BY COUNT(DISTINCT investor_id) DESC;
      SQL
      run_chart_query(sql)
    end

    def aggregate_country_distribution
      sql = <<~SQL
        SELECT c.name AS label, COUNT(DISTINCT s.investor_id) AS count
        FROM public.investment_strategies s
        INNER JOIN public.investment_strategy_country_focus cf ON cf.investment_strategy_id = s.id
        INNER JOIN public.countries c ON c.id = cf.country_id
        WHERE s.investor_id IS NOT NULL
          AND c.name IS NOT NULL
        GROUP BY c.name
        ORDER BY COUNT(DISTINCT s.investor_id) DESC;
      SQL
      run_chart_query(sql)
    end

    def aggregate_region_distribution
      sql = <<~SQL
        SELECT r.name AS label, COUNT(DISTINCT s.investor_id) AS count
        FROM public.investment_strategies s
        INNER JOIN public.investment_strategy_region_focus rf ON rf.investment_strategy_id = s.id
        INNER JOIN public.regions r ON r.id = rf.region_id
        WHERE s.investor_id IS NOT NULL
          AND r.name IS NOT NULL
        GROUP BY r.name
        ORDER BY COUNT(DISTINCT s.investor_id) DESC;
      SQL
      run_chart_query(sql)
    end

    def run_chart_query(sql)
      ActiveRecord::Base.connection.exec_query(sql).map do |row|
        {
          label: row["label"].to_s,
          count: row["count"].to_i
        }
      end
    end
  end
end
