module GraphqlApi
  class AnalyticsTeamService
    include GraphqlSupport::PayloadHelpers

    ALL_ROLES = %w[Admin DataManager AccountManager].freeze

    def call
      role_ids = Role.where(name: ALL_ROLES).pluck(:id)
      users = User.joins(:user_roles).where(user_roles: { role_id: role_ids }).distinct
      start_date = 6.months.ago.to_date

      deep_camelize(
        users.map do |user|
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
      )
    end
  end
end
