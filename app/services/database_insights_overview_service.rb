class DatabaseInsightsOverviewService
  ACTIVITY_WINDOW = 6.months

  def call
    {
      kpi_stats: kpi_stats,
      activity_timeline: activity_timeline
    }
  rescue StandardError => e
    ErrorLogger.error("DatabaseInsightsOverviewService#call: #{e.class} - #{e.message}")
    raise e
  end

  private

  def kpi_stats
    {
      total_investors: metric(investors_total, investors_week_old),
      total_qualified: metric(qualified_total, qualified_week_old),
      total_contacts: metric(contacts_total, contacts_week_old),
      total_proof_points: metric(proof_total, proof_week_old),
      new_investor_rate: metric(new_investors_this_month, new_investors_last_month),
      qualified_investor_rate: metric(qualified_this_month, qualified_last_month)
    }
  end

  def activity_timeline
    added_counts = Investor
                   .where("created_at_utc >= ?", activity_start_date)
                   .group("DATE(created_at_utc)")
                   .count
    qualified_counts = Investor
                       .where(qualified: true)
                       .where("qualified_at_utc >= ?", activity_start_date)
                       .group("DATE(qualified_at_utc)")
                       .count

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
    timeline
  end

  def investors_total = Investor.count
  def investors_week_old = Investor.where("created_at_utc <= ?", week_ago).count
  def qualified_total = Investor.where(qualified: true).count
  def qualified_week_old = Investor.where(qualified: true).where("qualified_at_utc <= ?", week_ago).count
  def contacts_total = InvestorContact.count
  def contacts_week_old = InvestorContact.where("created_at_utc <= ?", week_ago).count
  def proof_total = ProofLedger.count
  def proof_week_old = ProofLedger.where("created_at_utc <= ?", week_ago).count
  def new_investors_this_month = Investor.where("created_at_utc >= ?", month_ago).count
  def new_investors_last_month = Investor.where("created_at_utc >= ? AND created_at_utc < ?", two_months_ago, month_ago).count
  def qualified_this_month = Investor.where(qualified: true).where("qualified_at_utc >= ?", month_ago).count
  def qualified_last_month = Investor.where(qualified: true).where("qualified_at_utc >= ? AND qualified_at_utc < ?", two_months_ago, month_ago).count

  def week_ago = @week_ago ||= 7.days.ago
  def month_ago = @month_ago ||= 1.month.ago
  def two_months_ago = @two_months_ago ||= 2.months.ago
  def activity_start_date = @activity_start_date ||= ACTIVITY_WINDOW.ago.to_date

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
