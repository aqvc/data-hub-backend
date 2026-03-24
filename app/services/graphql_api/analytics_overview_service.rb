module GraphqlApi
  class AnalyticsOverviewService
    include GraphqlSupport::PayloadHelpers

    def call
      week_ago = 7.days.ago
      month_ago = 1.month.ago
      two_months_ago = 2.months.ago
      activity_start_date = 6.months.ago.to_date

      investors_total = Investor.count
      investors_week_old = Investor.where("created_at_utc <= ?", week_ago).count

      qualified_total = Investor.where(qualified: true).count
      qualified_week_old = Investor.where(qualified: true).where("qualified_at_utc <= ?", week_ago).count

      contacts_total = InvestorContact.count
      contacts_week_old = InvestorContact.where("created_at_utc <= ?", week_ago).count

      proof_total = ProofLedger.count
      proof_week_old = ProofLedger.where("created_at_utc <= ?", week_ago).count

      new_investors_this_month = Investor.where("created_at_utc >= ?", month_ago).count
      new_investors_last_month = Investor.where("created_at_utc >= ? AND created_at_utc < ?", two_months_ago, month_ago).count

      qualified_this_month = Investor.where(qualified: true).where("qualified_at_utc >= ?", month_ago).count
      qualified_last_month = Investor.where(qualified: true).where("qualified_at_utc >= ? AND qualified_at_utc < ?", two_months_ago, month_ago).count

      added_counts = Investor.where("created_at_utc >= ?", activity_start_date).group("DATE(created_at_utc)").count
      qualified_counts = Investor.where(qualified: true).where("qualified_at_utc >= ?", activity_start_date).group("DATE(qualified_at_utc)").count

      timeline = []
      day = activity_start_date
      while day <= Date.current
        timeline << {
          date: day.strftime("%Y-%m-%d"),
          added_count: added_counts[day] || 0,
          qualified_count: qualified_counts[day] || 0
        }
        day += 1.day
      end

      deep_camelize(
        kpi_stats: {
          total_investors: metric(investors_total, investors_week_old),
          total_qualified: metric(qualified_total, qualified_week_old),
          total_contacts: metric(contacts_total, contacts_week_old),
          total_proof_points: metric(proof_total, proof_week_old),
          new_investor_rate: metric(new_investors_this_month, new_investors_last_month),
          qualified_investor_rate: metric(qualified_this_month, qualified_last_month)
        },
        activity_timeline: timeline
      )
    end

    private

    def metric(current, old)
      growth_rate =
        if old.to_i <= 0
          current.to_i.positive? ? 100.0 : 0.0
        else
          (((current.to_f - old.to_f) / old.to_f) * 100.0).round(1)
        end

      { total: current, growth_rate: growth_rate }
    end
  end
end
