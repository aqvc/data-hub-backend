require "roo"

module Importers
  class UnqualifiedInvestorsXlsxImporter
    DEFAULT_PATH = Rails.root.join("tmp/imports/unqualified_investors.xlsx").to_s
    CANONICAL_REGIONS = [
      "Asia",
      "Africa",
      "Europe",
      "Oceania",
      "Caribbean",
      "South America",
      "North America",
      "Middle East",
      "Eastern Europe",
      "Europe/Asia",
      "Global",
      "Asia/Pacific"
    ].freeze

    HEADER_ALIASES = {
      external_id: ["Investor ID", "ID", "External ID"],
      name: ["Name", "Investor Name", "Firm Name"],
      investor_type: ["Type", "Investor Type"],
      website: ["Website", "Website URL"],
      linkedin: ["Linkedin", "LinkedIn", "LinkedIn URL"],
      aum: ["AUM Approx", "AUM", "Aum"],
      description: ["Descriptions", "Description", "Internal Description"],
      comments: ["Comments", "Comment", "Notes"],
      source: ["Sources", "Source"],
      qualified: ["Qualified"],
      region: ["Region", "Region Focus", "Headquarter Region"],
      country: ["Country", "Country Headquater", "Country Headquarter"],
      city: ["Location", "City", "Headquarter City"]
    }.freeze

    COUNTRY_ALIASES = {
      "united states of america" => "United States",
      "u.s.a" => "United States",
      "usa" => "United States",
      "uk" => "United Kingdom",
      "u.k." => "United Kingdom",
      "uae" => "United Arab Emirates",
      "u.a.e" => "United Arab Emirates"
    }.freeze
    REGION_ALIASES = {
      "america" => "North America",
      "americas" => "North America",
      "na" => "North America",
      "north america" => "North America",
      "eu" => "Europe",
      "uk/europe" => "Europe",
      "apac" => "Asia/Pacific",
      "asia pacific" => "Asia/Pacific",
      "middle-east" => "Middle East",
      "middle east and north africa" => "Middle East",
      "mena" => "Middle East",
      "latam" => "South America",
      "latin america" => "South America",
      "global" => "Global",
      "world" => "Global",
      "worldwide" => "Global"
    }.freeze

    def initialize(file_path: DEFAULT_PATH, dry_run: false, user_id: nil, sheet_name: nil, logger: $stdout)
      @file_path = file_path
      @dry_run = dry_run
      @sheet_name = sheet_name
      @logger = logger
      @user_id = user_id.presence || User.order(:created_at_utc).limit(1).pick(:id)
      raise "No user found. Pass USER_ID=<uuid>." if @user_id.blank?

      @stats = Hash.new(0)
      @errors = []
      @countries_by_name = {}
      @regions_by_name = {}
      @regions_by_id = {}
      @country_ids_by_region_id = Hash.new { |h, k| h[k] = [] }
      @currencies_by_code = {}
      @currencies_by_name = {}
      @investor_types_by_external_id = Hash.new { |h, k| h[k] = [] }
      @investor_regions_by_external_id = Hash.new { |h, k| h[k] = [] }
      @investor_countries_by_external_id = Hash.new { |h, k| h[k] = [] }
      @external_investor_to_uuid = {}
      @strategy_to_external_investor = {}
      @ambiguous_investor_types = []
    end

    def run
      workbook = Roo::Excelx.new(@file_path)
      investors_sheet_name = pick_sheet_name(workbook)

      cache_reference_data
      cache_currency_data
      build_optional_investor_maps(workbook)
      build_strategy_investor_map(workbook)

      ActiveRecord::Base.transaction do
        sheet = workbook.sheet(investors_sheet_name)
        each_row(sheet) do |row|
          import_investor_row(row)
        end
        import_investment_strategies(workbook)
        import_investment_vehicles_and_links(workbook)
        raise ActiveRecord::Rollback if @dry_run
      end

      print_summary
    end

    private

    def pick_sheet_name(workbook)
      return @sheet_name if @sheet_name.present?

      workbook.sheets.first
    end

    def cache_reference_data
      @countries_by_name = Country.all.index_by { |c| normalize_country_key(c.name) }
      @regions_by_name = Region.all.index_by { |r| normalize_key(r.name) }
      @regions_by_id = Region.all.index_by(&:id)
      @country_ids_by_region_id = Country.all.group_by(&:region_id).transform_values { |rows| rows.map(&:id) }
    end

    def cache_currency_data
      @currencies_by_code = Currency.where.not(code: [nil, ""]).index_by { |c| normalize_key(c.code) }
      @currencies_by_name = Currency.where.not(name: [nil, ""]).index_by { |c| normalize_key(c.name) }
    end

    def each_row(sheet)
      headers = sheet.row(1).map { |value| value.to_s.strip }
      2.upto(sheet.last_row) do |row_index|
        values = sheet.row(row_index)
        row = headers.each_with_index.each_with_object({}) do |(header, i), memo|
          memo[header] = values[i]
        end
        yield(row)
      rescue StandardError => e
        current_sheet_name = sheet.respond_to?(:default_sheet) ? sheet.default_sheet : sheet.name
        @errors << "Sheet '#{current_sheet_name}' row #{row_index}: #{e.message}"
      end
    end

    def import_investor_row(row)
      external_id = value_for(row, :external_id).to_s.strip
      name = value_for(row, :name).to_s.strip
      return if name.blank?

      type_value = resolve_investor_type_value(external_id, value_for(row, :investor_type))
      region_value = resolve_investor_region_value(external_id, value_for(row, :region))
      country_value = resolve_investor_country_value(external_id, value_for(row, :country))

      investor = Investor.find_or_initialize_by(name: name)
      investor.type = map_investor_type(type_value)
      investor.website_url = value_for(row, :website).to_s.strip.presence
      investor.linked_in_url = value_for(row, :linkedin).to_s.strip.presence
      investor.aum_aprox_in_usd = to_decimal(value_for(row, :aum))
      investor.description = value_for(row, :description).to_s.strip.presence
      investor.internal_description = value_for(row, :comments).to_s.strip.presence
      investor.source = value_for(row, :source).to_s.strip.presence

      qualified_cell = value_for(row, :qualified)
      investor.qualified = if qualified_cell.nil?
                             false
                           else
                             to_boolean(qualified_cell).nil? ? false : to_boolean(qualified_cell)
                           end

      investor.created_by_id ||= @user_id
      investor.updated_by_id = @user_id if investor.respond_to?(:updated_by_id=)
      investor.created_at_utc ||= Time.current.utc
      investor.updated_at_utc = Time.current.utc if investor.respond_to?(:updated_at_utc=)

      location = find_or_build_location(
        country_name: country_value,
        region_name: region_value,
        city: value_for(row, :city)
      )
      investor.location_id = location.id if location

      save_record(investor, :investors)
      sync_investor_currencies(investor.id, row["Currency"])
      @external_investor_to_uuid[external_id] = investor.id if external_id.present? && investor.id.present?
    end

    def value_for(row, key)
      aliases = HEADER_ALIASES.fetch(key)
      header = aliases.find { |candidate| row.key?(candidate) }
      row[header]
    end

    def build_optional_investor_maps(workbook)
      load_map_sheet(workbook, "Investor Type Map", "Investor ID", "Type", @investor_types_by_external_id)
      load_map_sheet(workbook, "Investor Region Map", "Investor ID", "Region", @investor_regions_by_external_id)
      load_map_sheet(workbook, "Investor Country Map", "Investor ID", "Country", @investor_countries_by_external_id)
    end

    def build_strategy_investor_map(workbook)
      return unless workbook.sheets.include?("Investment Vehicles")

      each_row(workbook.sheet("Investment Vehicles")) do |row|
        strategy_id = row["Investment Strategy"].to_s.strip
        external_investor_id = row["Investor"].to_s.strip
        next if strategy_id.blank? || external_investor_id.blank?

        @strategy_to_external_investor[strategy_id] = external_investor_id
      end
    end

    def load_map_sheet(workbook, sheet_name, key_header, value_header, store)
      return unless workbook.sheets.include?(sheet_name)

      sheet = workbook.sheet(sheet_name)
      headers = sheet.row(1).map { |value| value.to_s.strip }
      key_index = headers.index(key_header)
      value_index = headers.index(value_header)
      return if key_index.nil? || value_index.nil?

      2.upto(sheet.last_row) do |row_index|
        values = sheet.row(row_index)
        external_id = values[key_index].to_s.strip
        value = values[value_index].to_s.strip
        next if external_id.blank? || value.blank?

        store[external_id] << value
      end
    end

    def resolve_investor_type_value(external_id, row_type)
      candidates = [row_type, *@investor_types_by_external_id[external_id]].flat_map { |value| split_multi_values(value) }.uniq
      return row_type if candidates.empty?

      mapped = candidates.map { |value| [value, map_investor_type(value)] }
      preferred = mapped.find { |_raw, mapped_value| mapped_value != "other" }
      chosen = (preferred || mapped.first)&.first

      mapped_values = mapped.map(&:last).uniq
      if mapped_values.size > 1 && @ambiguous_investor_types.size < 50
        @ambiguous_investor_types << "#{external_id}: #{candidates.uniq.join(' | ')} -> using '#{chosen}'"
      end

      chosen
    end

    def resolve_investor_region_value(external_id, row_region)
      row_candidates = split_multi_values(row_region)
      return row_candidates.first if row_candidates.any?

      split_multi_values(@investor_regions_by_external_id[external_id].first).first
    end

    def resolve_investor_country_value(external_id, row_country)
      row_candidates = split_multi_values(row_country).map { |value| canonical_country_name(value) }
      return row_candidates.first if row_candidates.any?

      map_candidates = split_multi_values(@investor_countries_by_external_id[external_id].first).map { |value| canonical_country_name(value) }
      map_candidates.first
    end

    def find_or_build_location(country_name:, region_name:, city:)
      country_id = country_id_by_name(country_name, region_name)
      return nil if country_id.blank?

      location = Location.find_or_initialize_by(
        country_id: country_id,
        city: city.to_s.strip.presence
      )
      location.location_type ||= "primary"
      location.created_by_id ||= @user_id
      location.updated_by_id = @user_id if location.respond_to?(:updated_by_id=)
      location.created_at_utc ||= Time.current.utc
      location.updated_at_utc = Time.current.utc if location.respond_to?(:updated_at_utc=)
      save_record(location, :locations)
      location
    end

    def import_investment_strategies(workbook)
      return unless workbook.sheets.include?("Investment Strategy")

      each_row(workbook.sheet("Investment Strategy")) do |row|
        strategy_id = row["ID"].to_s.strip
        next if strategy_id.blank?

        region_focus_ids = resolve_region_focus_ids(
          region_value: row["Region focus"],
          country_value: row["Country Focus"]
        )
        country_focus_ids = resolve_country_focus_ids(
          country_value: row["Country Focus"],
          region_ids: region_focus_ids
        )

        strategy = InvestmentStrategy.find_or_initialize_by(id: strategy_id)
        strategy.name = row["Name"].to_s.strip.presence || "Default"
        strategy.investor_id ||= investor_uuid_for_strategy(strategy_id)
        strategy.stage_focus = map_multi_values(row["Stage Focus"]) { |value| map_stage(value) }
        strategy.sector_investment_focus = map_multi_values(row["Sector Focus"]) { |value| map_sector(value) }
        strategy.maturity_focus ||= []
        strategy.asset_class_focus ||= []
        strategy.investor_type_focus ||= []
        strategy.strategy_focus ||= []
        strategy.min_check_size = to_decimal(row["Min Ticket Size"])
        strategy.max_check_size = to_decimal(row["Max Ticket Size"])
        strategy.country_headquarter_id = country_focus_ids.first
        strategy.region_headquarter_id = region_focus_ids.first
        strategy.created_by_id ||= @user_id
        strategy.updated_by_id = @user_id if strategy.respond_to?(:updated_by_id=)
        strategy.created_at_utc ||= Time.current.utc
        strategy.updated_at_utc = Time.current.utc if strategy.respond_to?(:updated_at_utc=)
        save_record(strategy, :investment_strategies)

        region_focus_ids.each do |region_id|
          focus = InvestmentStrategyRegionFocus.find_or_initialize_by(
            investment_strategy_id: strategy.id,
            region_id: region_id
          )
          save_record(focus, :investment_strategy_region_focus)
        end

        country_focus_ids.each do |country_id|
          focus = InvestmentStrategyCountryFocus.find_or_initialize_by(
            investment_strategy_id: strategy.id,
            country_id: country_id
          )
          save_record(focus, :investment_strategy_country_focus)
        end
      end
    end

    def import_investment_vehicles_and_links(workbook)
      return unless workbook.sheets.include?("Investment Vehicles")

      each_row(workbook.sheet("Investment Vehicles")) do |row|
        vehicle_id = row["ID"].to_s.strip
        external_investor_id = row["Investor"].to_s.strip
        strategy_id = row["Investment Strategy"].to_s.strip
        next if vehicle_id.blank? || external_investor_id.blank?

        investor_id = @external_investor_to_uuid[external_investor_id]
        next if investor_id.blank?

        vehicle = InvestmentVehicle.find_or_initialize_by(id: vehicle_id)
        vehicle.investor_id = investor_id
        vehicle.name = row["Name"].to_s.strip.presence || "Default"
        vehicle.type = map_vehicle_type(row["Vehicle Type"])
        vehicle.fund_status = map_simple_enum(row["Fund Status"], %w[open closed])
        vehicle.investing_status = map_simple_enum(row["Investment Status"], %w[investing not_investing])
        vehicle.fund_size = to_decimal(row["Fund size"])
        vehicle.target_size = to_decimal(row["Target Size"])
        vehicle.number_of_investments = to_integer(row["Number of investments"])
        vehicle.last_investment = to_time(row["Last investment date"])
        vehicle.currency_id = currency_id(row["Currency"])
        vehicle.vintage_year = to_integer(row["Vintage"])
        vehicle.created_by_id ||= @user_id
        vehicle.updated_by_id = @user_id if vehicle.respond_to?(:updated_by_id=)
        vehicle.created_at_utc ||= Time.current.utc
        vehicle.updated_at_utc = Time.current.utc if vehicle.respond_to?(:updated_at_utc=)
        save_record(vehicle, :investment_vehicles)

        next if strategy_id.blank?

        link = InvestmentVehicleInvestmentStrategy.find_or_initialize_by(
          investment_vehicle_id: vehicle.id,
          investment_strategy_id: strategy_id
        )
        save_record(link, :investment_vehicles_investment_strategies)
      end
    end

    def country_id_by_name(country_name, region_name)
      key = normalize_country_key(country_name)
      return nil if key.blank?

      country = @countries_by_name[key]
      if country
        reconcile_country_region!(country, region_name)
        return country.id
      end

      @stats["country_values_ignored_unknown"] += 1
      nil
    end

    def region_id_by_name(region_name)
      canonical = canonical_region_name(region_name)
      return nil if canonical.blank?

      key = normalize_key(canonical)
      region = @regions_by_name[key]
      return region.id if region

      @stats["region_values_ignored_unknown"] += 1
      nil
    end

    def map_investor_type(value)
      norm = normalize_enum_value(value)
      return "other" if norm.blank?

      mapping = {
        "fund_of_fund" => "fund_of_funds",
        "fund_of_funds" => "fund_of_funds",
        "fund_of_funds_general" => "fund_of_funds",
        "family_offices" => "family_office",
        "multi_family_offices" => "multi_family_office",
        "asset_managers" => "asset_manager",
        "institutional_investors" => "institutional_investor",
        "banks" => "bank",
        "insurance_companies" => "insurance",
        "corporates" => "corporate"
      }
      mapped = mapping[norm] || norm
      Investor.types.key?(mapped) ? mapped : "other"
    end

    def map_vehicle_type(value)
      text = value.to_s.downcase
      return nil if text.blank?

      return "balance_sheet" if text.include?("balance")
      return "fund" if text.include?("fund") || text.include?("vc") || text.include?("debt")

      "other"
    end

    def map_sector(value)
      norm = normalize_enum_value(value)
      mapping = {
        "technology" => "technology_media_and_telecommunications",
        "software_as_a_service_saa_s" => "software_as_a_service",
        "saas" => "saa_s",
        "web3" => "blockchain_and_web3",
        "blockchain" => "blockchain_and_web3",
        "healthcare" => "health_tech",
        "agnostic" => "agnostic"
      }
      mapped = mapping[norm] || norm
      InvestmentStrategy::SECTOR_INVESTMENT_FOCUS_VALUES.include?(mapped) ? mapped : nil
    end

    def map_stage(value)
      norm = normalize_enum_value(value)
      return nil if norm == "series_c_"

      mapped = {
        "preseed" => "pre_seed",
        "seed_stage" => "seed"
      }[norm] || norm
      InvestmentStrategy::STAGE_FOCUS_VALUES.include?(mapped) ? mapped : nil
    end

    def map_simple_enum(value, allowed_values)
      norm = normalize_enum_value(value)
      allowed_values.include?(norm) ? norm : nil
    end

    def to_decimal(value)
      return nil if value.blank?

      cleaned = value.to_s.gsub(/[^\d\.\-]/, "")
      return nil if cleaned.blank?

      BigDecimal(cleaned)
    rescue ArgumentError
      nil
    end

    def to_integer(value)
      return nil if value.blank?

      value.to_i
    end

    def to_time(value)
      return nil if value.blank?

      return value.to_time if value.respond_to?(:to_time)

      Time.zone.parse(value.to_s)
    rescue StandardError
      nil
    end

    def to_boolean(value)
      return nil if value.nil?

      normalized = value.to_s.strip.downcase
      return nil if normalized.blank?
      return true if %w[true t yes y 1].include?(normalized)
      return false if %w[false f no n 0].include?(normalized)

      nil
    end

    def normalize_enum_value(value)
      value.to_s
           .strip
           .gsub("::", "/")
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr("-", "_")
           .tr(" ", "_")
           .gsub(/[^a-zA-Z0-9_]/, "_")
           .gsub(/_+/, "_")
           .downcase
           .sub(/^_/, "")
           .sub(/_$/, "")
    end

    def normalize_key(value)
      value.to_s.strip.downcase
    end

    def split_multi_values(value)
      value.to_s
           .split(/[,;\n]/)
           .map(&:strip)
           .reject(&:blank?)
    end

    def split_list(value)
      split_multi_values(value)
    end

    def compact_array(value)
      Array(value).flatten.compact.reject(&:blank?).uniq
    end

    def map_multi_values(value)
      items = split_list(value)
      items = [value] if items.empty? && value.present?
      compact_array(items.map { |item| yield(item) })
    end

    def canonical_country_name(value)
      raw = value.to_s.strip
      return raw if raw.blank?

      COUNTRY_ALIASES.fetch(raw.downcase, raw)
    end

    def normalize_country_key(value)
      normalize_key(canonical_country_name(value))
    end

    def currency_id(value)
      key = normalize_key(value)
      return nil if key.blank?

      @currencies_by_code[key]&.id || @currencies_by_name[key]&.id
    end

    def sync_investor_currencies(investor_id, currency_value)
      return if investor_id.blank?

      split_multi_values(currency_value).each do |currency_text|
        currency_uuid = currency_id(currency_text)
        next if currency_uuid.blank?

        currency_link = InvestorCurrency.find_or_initialize_by(
          investor_id: investor_id,
          currency_id: currency_uuid
        )
        save_record(currency_link, :investor_currencies)
      end
    end

    def investor_uuid_for_strategy(strategy_id)
      external = @strategy_to_external_investor[strategy_id]
      return nil if external.blank?

      @external_investor_to_uuid[external]
    end

    def resolve_region_focus_ids(region_value:, country_value:)
      regions = split_region_values(region_value)
      region_ids = regions.flat_map do |region_name|
        if %w[global worldwide world].include?(normalize_key(region_name))
          @regions_by_id.keys
        else
          [region_id_by_name(region_name)]
        end
      end.compact.uniq
      return region_ids if region_ids.any?

      first_country = split_multi_values(country_value).map { |v| canonical_country_name(v) }.first
      country = @countries_by_name[normalize_country_key(first_country)]
      return [] unless country&.region_id

      [country.region_id]
    end

    def resolve_country_focus_ids(country_value:, region_ids:)
      explicit_country_ids = split_multi_values(country_value).filter_map do |country_name|
        country_id_by_name(canonical_country_name(country_name), region_name_by_id(region_ids.first))
      end
      return explicit_country_ids.uniq if explicit_country_ids.any?
      return [] if region_ids.blank?

      region_ids.flat_map { |region_id| @country_ids_by_region_id[region_id] || [] }.uniq
    end

    def split_region_values(value)
      split_list(value)
        .map { |item| canonical_region_name(item) }
        .reject(&:blank?)
        .uniq
    end

    def region_name_by_id(region_id)
      return nil if region_id.blank?

      @regions_by_id[region_id]&.name
    end

    def canonical_region_name(value)
      raw = value.to_s.strip
      return nil if raw.blank?

      normalized = raw.gsub(/\(.*?\)/, "").strip
      candidate = REGION_ALIASES[normalized.downcase] || normalized
      canonical = CANONICAL_REGIONS.find { |name| normalize_key(name) == normalize_key(candidate) }
      canonical
    end

    def reconcile_country_region!(country, region_name)
      target_region_id = region_id_by_name(region_name)
      return if target_region_id.blank?
      return if country.region_id.to_s == target_region_id.to_s

      global_region_id = @regions_by_name[normalize_key("Global")]&.id
      if target_region_id.to_s == global_region_id.to_s &&
         country.region_id.present? &&
         country.region_id.to_s != global_region_id.to_s
        return
      end

      previous_region_id = country.region_id
      country.region_id = target_region_id
      country.updated_at_utc = Time.current.utc if country.respond_to?(:updated_at_utc=)
      save_record(country, :countries_updated)

      if previous_region_id.present?
        @country_ids_by_region_id[previous_region_id]&.delete(country.id)
      end
      @country_ids_by_region_id[target_region_id] ||= []
      unless @country_ids_by_region_id[target_region_id].include?(country.id)
        @country_ids_by_region_id[target_region_id] << country.id
      end
    end

    def fallback_code(value, length, default)
      cleaned = value.to_s.gsub(/[^A-Za-z]/, "").upcase
      return default if cleaned.blank?

      cleaned.first(length).ljust(length, "X")
    end

    def save_record(record, counter_key)
      if @dry_run
        @stats["#{counter_key}_would_save"] += 1
        return true
      end

      if record.save
        @stats["#{counter_key}_saved"] += 1
        true
      else
        @errors << "#{record.class.name} #{record.try(:id) || '(new)'}: #{record.errors.full_messages.join(', ')}"
        @stats["#{counter_key}_failed"] += 1
        false
      end
    end

    def print_summary
      @logger.puts "\nUnqualified import finished#{@dry_run ? ' (DRY RUN)' : ''}"
      @stats.keys.sort.each { |key| @logger.puts " - #{key}: #{@stats[key]}" }
      if @ambiguous_investor_types.any?
        @logger.puts "\nAmbiguous investor type rows (showing up to 50):"
        @ambiguous_investor_types.each { |line| @logger.puts " - #{line}" }
      end
      if @errors.any?
        @logger.puts "\nErrors (#{@errors.size}):"
        @errors.first(100).each { |error| @logger.puts " - #{error}" }
        @logger.puts " - ...and #{@errors.size - 100} more" if @errors.size > 100
      end
    end
  end
end
