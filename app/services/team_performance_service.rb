class TeamPerformanceService
  ACTIVITY_WINDOW = 6.months

  def initialize(role_names)
    @role_names = role_names
  end

  def call
    users.map { |user| build_user_summary(user) }
  rescue StandardError => e
    ErrorLogger.error("TeamPerformanceService#call: #{e.class} - #{e.message}")
    raise e
  end

  private

  def users
    User.with_any_role(*@role_names)
  end

  def start_date
    @start_date ||= ACTIVITY_WINDOW.ago.to_date
  end

  def build_user_summary(user)
    created_scope = Investor.where(created_by_id: user.id)
    qualified_scope = Investor.where(qualified_by_id: user.id, qualified: true)
    proof_scope = ProofLedger.where(created_by_id: user.id)

    {
      user_id: user.id,
      user_name: user.user_name.presence || user.email,
      user_created_at: user.created_at,
      total_created_all_time: created_scope.count,
      total_qualified_all_time: qualified_scope.count,
      total_proof_points_all_time: proof_scope.count,
      actions: build_actions(created_scope, qualified_scope, proof_scope)
    }
  end

  def build_actions(created_scope, qualified_scope, proof_scope)
    created_daily = created_scope.where("created_at_utc >= ?", start_date).group("DATE(created_at_utc)").count
    qualified_daily = qualified_scope.where("qualified_at_utc >= ?", start_date).group("DATE(qualified_at_utc)").count
    proof_daily = proof_scope.where("created_at_utc >= ?", start_date).group("DATE(created_at_utc)").count

    all_dates = (created_daily.keys + qualified_daily.keys + proof_daily.keys).uniq.sort
    all_dates.map do |date|
      {
        date: date.to_s,
        created_count: created_daily[date] || 0,
        qualified_count: qualified_daily[date] || 0,
        proof_points_count: proof_daily[date] || 0
      }
    end
  end
end
