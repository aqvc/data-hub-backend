module Api
  class AnalyticsController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = %w[Admin DataManager AccountManager].freeze

    before_action do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def database_insights_overview
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

      render json: deep_camelize(
        kpi_stats: {
          total_investors: metric(investors_total, investors_week_old),
          total_qualified: metric(qualified_total, qualified_week_old),
          total_contacts: metric(contacts_total, contacts_week_old),
          total_proof_points: metric(proof_total, proof_week_old),
          new_investor_rate: metric(new_investors_this_month, new_investors_last_month),
          qualified_investor_rate: metric(qualified_this_month, qualified_last_month)
        },
        activity_timeline: timeline
      ), status: :ok
    end

    def database_insights_distributions
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

        list.flat_map { |s| Array(s.sector_investment_focus) }.uniq.each { |v| by_sector[v.to_s] += 1 if v.present? }
        list.flat_map { |s| Array(s.stage_focus) }.uniq.each { |v| by_stage[v.to_s] += 1 if v.present? }
        list.flat_map { |s| Array(s.maturity_focus) }.uniq.each { |v| by_maturity[v.to_s] += 1 if v.present? }
        list.flat_map { |s| s.investment_strategy_country_focuses.map { |f| f.country&.name } }.compact.uniq.each { |v| by_country[v] += 1 }
        list.flat_map { |s| s.investment_strategy_region_focuses.map { |f| f.region&.name } }.compact.uniq.each { |v| by_region[v] += 1 }
      end

      render json: deep_camelize(
        by_type: to_chart_data(by_type),
        by_sector: to_chart_data(by_sector),
        by_stage: to_chart_data(by_stage),
        by_country: to_chart_data(by_country),
        by_region: to_chart_data(by_region),
        by_maturity: to_chart_data(by_maturity)
      ), status: :ok
    end

    def team
      role_ids = Role.where(name: ALL_ROLES).pluck(:id)
      users = User.joins(:user_roles).where(user_roles: { role_id: role_ids }).distinct
      start_date = 6.months.ago.to_date

      response = users.map do |user|
        created_scope = Investor.where(created_by_id: user.id)
        qualified_scope = Investor.where(qualified_by_id: user.id, qualified: true)
        proof_scope = ProofLedger.where(created_by_id: user.id)

        created_daily = created_scope.where("created_at_utc >= ?", start_date).group("DATE(created_at_utc)").count
        qualified_daily = qualified_scope.where("qualified_at_utc >= ?", start_date).group("DATE(qualified_at_utc)").count
        proof_daily = proof_scope.where("created_at_utc >= ?", start_date).group("DATE(created_at_utc)").count

        all_dates = (created_daily.keys + qualified_daily.keys + proof_daily.keys).uniq.sort
        actions = all_dates.map do |date|
          {
            date: date.to_s,
            created_count: created_daily[date] || 0,
            qualified_count: qualified_daily[date] || 0,
            proof_points_count: proof_daily[date] || 0
          }
        end

        {
          user_id: user.id,
          user_name: user.user_name.presence || user.email,
          user_created_at: user.created_at,
          total_created_all_time: created_scope.count,
          total_qualified_all_time: qualified_scope.count,
          total_proof_points_all_time: proof_scope.count,
          actions: actions
        }
      end

      render json: deep_camelize(response), status: :ok
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

    def to_chart_data(hash)
      hash.map { |label, count| { label: label, count: count } }
          .sort_by { |point| -point[:count] }
    end
  end
end
