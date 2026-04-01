module GraphqlApi
  # Builds one SQL query for Investor filtering by accumulating EXISTS subqueries
  # (for association filters) and direct WHERE conditions (for investor-table columns),
  # then combining them with AND or OR based on joinOperator.
  #
  # Input JSON shape:
  #   {
  #     "joinOperator": "and" | "or",
  #     "filterList": {
  #       "investorType":          [{ "value": ["family_office"], "operator": "inArray" }],
  #       "sectorInvestmentFocus": [{ "operator": "isEmpty" }],
  #       "headquarterCity":       [{ "value": "NYC", "operator": "iLike" }]
  #     }
  #   }
  #
  # Usage:
  #   builder = InvestorQueryBuilder.new(join_operator: "and")
  #   builder.add_filter(id: "investorType", operator: "inArray", values: ["family_office"])
  #   builder.add_filter(id: "sectorInvestmentFocus", operator: "isEmpty", values: [])
  #   scope = builder.build(Investor.all)
  class InvestorQueryBuilder
    # Each fragment is a pre-sanitized SQL string (no unbound params).
    # We use sanitize_sql_array to eagerly bind values so fragments can be
    # freely combined with AND / OR without tracking positional placeholders.

    def initialize(join_operator: "and")
      @or_mode = join_operator.to_s.strip.downcase == "or"
      @fragments = []
    end

    # Add one filter condition. Call multiple times before calling build.
    def add_filter(id:, operator:, values:)
      fragment = build_fragment(id.to_s, operator.to_s, Array(values))
      @fragments << fragment if fragment.present?
      self
    end

    # Returns an ActiveRecord relation. Pass your base scope (defaults to Investor.all).
    def build(base_scope = Investor.all)
      return base_scope if @fragments.empty?

      combinator = @or_mode ? " OR " : " AND "
      combined   = @fragments.join(combinator)
      base_scope.where("(#{combined})").distinct
    end

    # Convenience: build directly from the parsed filterList hash.
    # Each key maps to an array of rule hashes with "operator" and optional "value".
    def self.from_filter(filter_list, join_operator: "and")
      builder = new(join_operator: join_operator)

      (filter_list || {}).each do |id, rules|
        Array(rules).each do |rule|
          rule_hash = rule.respond_to?(:to_h) ? rule.to_h : rule.to_unsafe_h
          operator  = rule_hash["operator"].presence || "eq"
          values    = normalize_values(rule_hash["value"])
          builder.add_filter(id: id.to_s, operator: operator, values: values)
        end
      end

      builder
    end

    def self.normalize_values(raw)
      Array(raw)
        .flat_map { |v| v.is_a?(Array) ? v : [v] }
        .map { |v| v.is_a?(String) ? v.strip : v }
        .reject { |v| v.nil? || v == "" }
    end

    private

    # -------------------------------------------------------------------------
    # Dispatcher: maps filter id → SQL fragment string
    # -------------------------------------------------------------------------
    def build_fragment(id, operator, values)
      case id
      # ── Direct investor-table columns ──────────────────────────────────────
      when "investorType"
        direct_scalar("public.investors.type", operator, values)

      when "qualified"
        direct_boolean("public.investors.qualified", operator, values)

      when "organization"
        direct_scalar("public.investors.organization_profile_id", operator, values)

      # ── IIP (inner join — investor must have a matching IIP row) ───────────
      when "iip"
        exists_fragment(
          from:      "public.ideal_investor_profiles iip_tbl",
          join_type: "INNER",
          on:        "iip_tbl.organization_profile_id::text = public.investors.organization_profile_id::text",
          condition: scalar_condition("iip_tbl.id", operator, values)
        )

      # ── Location → city ───────────────────────────────────────────────────
      when "headquarterCity"
        exists_fragment(
          from:      "public.locations loc",
          on:        "loc.id::text = public.investors.location_id::text",
          condition: text_condition("loc.city", operator, values)
        )

      # ── Location → country ────────────────────────────────────────────────
      when "headquarterCountry"
        exists_fragment(
          from:        "public.locations loc",
          on:          "loc.id::text = public.investors.location_id::text",
          extra_joins: ["LEFT JOIN public.countries cntry ON cntry.id::text = loc.country_id::text"],
          condition:   scalar_condition("cntry.id", operator, values)
        )

      # ── Location → country → region ───────────────────────────────────────
      when "headquarterRegion"
        exists_fragment(
          from:        "public.locations loc",
          on:          "loc.id::text = public.investors.location_id::text",
          extra_joins: [
            "LEFT JOIN public.countries cntry ON cntry.id::text = loc.country_id::text",
            "LEFT JOIN public.regions rgn ON rgn.id::text = cntry.region_id::text"
          ],
          condition: scalar_condition("rgn.id", operator, values)
        )

      # ── Investment strategy array columns ─────────────────────────────────
      when "assetClassFocus"
        exists_strategy_array("s.asset_class_focus", operator, values)

      when "sectorInvestmentFocus"
        exists_strategy_array("s.sector_investment_focus", operator, values)

      when "maturityFocus"
        exists_strategy_array("s.maturity_focus", operator, values)

      when "investorTypeFocus"
        exists_strategy_array("s.investor_type_focus", operator, values)

      when "stageFocus"
        exists_strategy_array("s.stage_focus", operator, values)

      # ── Investment strategy → region focus ────────────────────────────────
      when "regionInvestmentFocus"
        exists_fragment(
          from:        "public.investment_strategies s",
          on:          "s.investor_id::text = public.investors.id::text",
          extra_joins: ["LEFT JOIN public.investment_strategy_region_focus rf ON rf.investment_strategy_id::text = s.id::text"],
          condition:   scalar_condition("rf.region_id", operator, values)
        )

      # ── Investment strategy → country focus ───────────────────────────────
      when "countryInvestmentFocus"
        exists_fragment(
          from:        "public.investment_strategies s",
          on:          "s.investor_id::text = public.investors.id::text",
          extra_joins: ["LEFT JOIN public.investment_strategy_country_focus cf ON cf.investment_strategy_id::text = s.id::text"],
          condition:   scalar_condition("cf.country_id", operator, values)
        )
      end
    end

    # -------------------------------------------------------------------------
    # EXISTS subquery builder
    # -------------------------------------------------------------------------
    # Produces:  EXISTS (SELECT 1 FROM <from> [INNER|LEFT] JOIN ... ON <on> [extra_joins...] WHERE <condition>)
    # join_type: "LEFT" (default) or "INNER" — the join between investors and the root FROM table
    def exists_fragment(from:, on:, condition:, extra_joins: [], join_type: "LEFT")
      return nil if condition.nil?

      extra_join_sql = extra_joins.join(" ")

      sanitize(
        <<~SQL.squish
          EXISTS (
            SELECT 1
            FROM #{from}
            #{extra_join_sql}
            WHERE #{on}
            AND (#{condition})
          )
        SQL
      )
    end

    # Shortcut for strategy array columns
    def exists_strategy_array(column, operator, values)
      condition = array_condition(column, operator, values)
      return nil if condition.nil?

      sanitize(
        <<~SQL.squish
          EXISTS (
            SELECT 1
            FROM public.investment_strategies s
            WHERE s.investor_id::text = public.investors.id::text
            AND (#{condition})
          )
        SQL
      )
    end

    # -------------------------------------------------------------------------
    # Direct WHERE helpers (for investor-table columns — no subquery needed)
    # -------------------------------------------------------------------------
    def direct_scalar(column, operator, values)
      scalar_condition(column, operator, values)
    end

    def direct_boolean(column, operator, values)
      boolean_condition(column, operator, values)
    end

    # -------------------------------------------------------------------------
    # Condition string generators (return pre-sanitized SQL strings)
    # -------------------------------------------------------------------------
    def scalar_condition(column, operator, values)
      case operator
      when "eq"
        return nil if values.empty?
        sanitize(["#{column} = ?", values.first])
      when "ne"
        return nil if values.empty?
        sanitize(["#{column} IS NULL OR #{column} <> ?", values.first])
      when "inArray"
        return nil if values.empty?
        sanitize(["#{column} IN (?)", values])
      when "notInArray"
        return nil if values.empty?
        sanitize(["(#{column} IS NULL OR #{column} NOT IN (?))", values])
      when "isEmpty"
        "#{column} IS NULL"
      when "isNotEmpty"
        "#{column} IS NOT NULL"
      when "iLike", "notILike"
        text_condition(column, operator, values)
      end
    end

    def text_condition(column, operator, values)
      case operator
      when "eq"
        return nil if values.empty?
        sanitize(["#{column} = ?", values.first])
      when "ne"
        return nil if values.empty?
        sanitize(["(#{column} IS NULL OR #{column} <> ?)", values.first])
      when "iLike"
        return nil if values.empty?
        sanitize(["LOWER(COALESCE(#{column}, '')) LIKE ?", "%#{values.first.to_s.downcase}%"])
      when "notILike"
        return nil if values.empty?
        sanitize(["LOWER(COALESCE(#{column}, '')) NOT LIKE ?", "%#{values.first.to_s.downcase}%"])
      when "inArray"
        return nil if values.empty?
        sanitize(["#{column} IN (?)", values])
      when "notInArray"
        return nil if values.empty?
        sanitize(["(#{column} IS NULL OR #{column} NOT IN (?))", values])
      when "isEmpty"
        "(#{column} IS NULL OR #{column} = '')"
      when "isNotEmpty"
        "(#{column} IS NOT NULL AND #{column} <> '')"
      end
    end

    # PostgreSQL array columns (stored as text[]).
    # Values are pre-normalized in Ruby (lowercase, stripped of non-alphanumeric chars)
    # so the SQL can do a plain equality check with no in-query regex.
    def array_condition(column, operator, values)
      normalized = normalize_filter_tokens(values)

      case operator
      when "eq", "inArray"
        return nil if normalized.empty?
        sanitize([
          "EXISTS (SELECT 1 FROM unnest(COALESCE(#{column}::text[], ARRAY[]::text[])) AS elem WHERE elem IN (?))",
          normalized
        ])
      when "ne", "notInArray"
        return nil if normalized.empty?
        sanitize([
          "NOT EXISTS (SELECT 1 FROM unnest(COALESCE(#{column}::text[], ARRAY[]::text[])) AS elem WHERE elem IN (?))",
          normalized
        ])
      when "isEmpty"
        "(#{column} IS NULL OR cardinality(#{column}) = 0)"
      when "isNotEmpty"
        "(#{column} IS NOT NULL AND cardinality(#{column}) > 0)"
      end
    end

    def boolean_condition(column, operator, values)
      bools = values.map { |v| normalize_boolean(v) }.compact.uniq

      case operator
      when "eq", "inArray"
        return nil if bools.empty?
        sanitize(["#{column} IN (?)", bools])
      when "ne", "notInArray"
        return nil if bools.empty?
        sanitize(["(#{column} IS NULL OR #{column} NOT IN (?))", bools])
      when "isEmpty"
        "#{column} IS NULL"
      when "isNotEmpty"
        "#{column} IS NOT NULL"
      end
    end

    # -------------------------------------------------------------------------
    # Utilities
    # -------------------------------------------------------------------------
    def sanitize(sql_array)
      if sql_array.is_a?(Array)
        ActiveRecord::Base.sanitize_sql_array(sql_array)
      else
        sql_array
      end
    end

    def normalize_filter_tokens(values)
      Array(values)
        .map { |v| v.to_s.strip.downcase }
        .reject(&:blank?)
        .uniq
    end

    def normalize_boolean(value)
      case value.to_s.strip.downcase
      when "true", "qualified"   then true
      when "false", "notqualified", "not qualified" then false
      end
    end
  end
end
