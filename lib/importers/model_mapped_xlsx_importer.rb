require "roo"
require "set"

module Importers
  class ModelMappedXlsxImporter
    DEFAULT_PATH = Rails.root.join("tmp/imports/DB_model_mapped_latest-Final.xlsx").to_s

    PROOF_FIELD_MAP = {
      "Asset Class" => "assetClassFocus",
      "Aum" => "aum",
      "Check Size" => "checkSize",
      "Country Focus" => "countryInvestmentFocus",
      "Country of Headquarter" => "headquarterCountry",
      "Fund Size" => "fundSize",
      "Impact Inevstment" => "impactInvestment",
      "Impact Investment" => "impactInvestment",
      "Impact Investmnet" => "impactInvestment",
      "Maturity Focus" => "maturityFocus",
      "Minimum & Maximum Check Size" => "minMaxCheckSize",
      "Minimum Check Size" => "minCheckSize",
      "Preferred Strategy" => "strategyFocus",
      "Region Focus" => "regionInvestmentFocus",
      "Region of Headquarter" => "headquarterRegion",
      "Sector Focus" => "sectorInvestmentFocus",
      "Stage Focus" => "stageFocus",
      "Type" => "investorType"
    }.freeze

    def initialize(file_path: DEFAULT_PATH, dry_run: false, user_id: nil, logger: $stdout)
      @file_path = file_path
      @dry_run = dry_run
      @logger = logger
      @user_id = user_id.presence || User.order(:created_at_utc).limit(1).pick(:id)
      raise "No user found. Pass USER_ID=<uuid>." if @user_id.blank?

      @external_investor_to_uuid = {}
      @strategy_to_external_investor = {}
      @stats = Hash.new(0)
      @errors = []
    end

    def run
      workbook = Roo::Excelx.new(@file_path)
      ensure_required_sheets!(workbook)

      cache_reference_data
      build_strategy_investor_map(workbook)

      ActiveRecord::Base.transaction do
        import_investors(workbook)
        import_investment_strategies(workbook)
        import_investment_vehicles_and_links(workbook)
        import_contacts(workbook)
        import_proof_ledgers(workbook)
        raise ActiveRecord::Rollback if @dry_run
      end

      print_summary
    end

    private

    def ensure_required_sheets!(workbook)
      required = [
        "Investors",
        "Investment Vehicles",
        "Investment Strategy",
        "Contacts",
        "Proof Ledger"
      ]
      missing = required - workbook.sheets
      raise "Missing required sheets: #{missing.join(', ')}" if missing.any?
    end

    def cache_reference_data
      @countries_by_name = Country.all.index_by { |c| normalize_key(c.name) }
      @regions_by_name = Region.all.index_by { |r| normalize_key(r.name) }
      @regions_by_id = Region.all.index_by(&:id)
      @currencies_by_name = Currency.all.index_by { |c| normalize_key(c.name) }
      @currencies_by_code = Currency.all.index_by { |c| normalize_key(c.code) }
      @country_ids_by_region_id = Country.all.group_by(&:region_id).transform_values { |rows| rows.map(&:id) }
    end

    def build_strategy_investor_map(workbook)
      each_row(workbook, "Investment Vehicles") do |row|
        strategy_id = row["Investment Strategy"].to_s.strip
        external_investor_id = row["Investor"].to_s.strip
        next if strategy_id.blank? || external_investor_id.blank?

        @strategy_to_external_investor[strategy_id] = external_investor_id
      end
    end

    def import_investors(workbook)
      each_row(workbook, "Investors") do |row|
        external_id = row["Investor ID"].to_s.strip
        name = row["Name"].to_s.strip
        next if external_id.blank? || name.blank?

        investor = Investor.find_or_initialize_by(name: name)
        investor.type = map_investor_type(row["Type"])
        investor.website_url = row["Website"].to_s.strip.presence
        investor.linked_in_url = row["Linkedin"].to_s.strip.presence
        investor.aum_aprox_in_currency = to_decimal(row["AUM Approx"])
        investor.internal_description = row["Descriptions"].to_s.strip.presence
        investor.source = row["Sources"].to_s.strip.presence
        qualified_value = to_boolean(row["Qualified"])
        investor.qualified = qualified_value.nil? ? (investor.qualified.nil? ? true : investor.qualified) : qualified_value
        investor.created_by_id ||= @user_id
        investor.updated_by_id = @user_id if investor.respond_to?(:updated_by_id=)
        investor.created_at_utc ||= Time.current.utc
        investor.updated_at_utc = Time.current.utc if investor.respond_to?(:updated_at_utc=)

        location = find_or_build_location(
          country_name: row["Country"],
          region_name: row["Region"],
          city: row["Location"]
        )
        investor.location_id = location.id if location
        save_record(investor, :investors)
        @external_investor_to_uuid[external_id] = investor.id if investor.id.present?
      end
    end

    def import_investment_strategies(workbook)
      each_row(workbook, "Investment Strategy") do |row|
        strategy_id = row["ID"].to_s.strip
        next if strategy_id.blank?

        region_focus_ids = resolve_region_focus_ids(
          region_value: row["Region focus"],
          country_value: row["Country Headquater"]
        )
        primary_region_id = region_focus_ids.first

        strategy = InvestmentStrategy.find_or_initialize_by(id: strategy_id)
        strategy.name = row["Name"].to_s.strip.presence || "Default"
        strategy.investor_id ||= investor_uuid_for_strategy(strategy_id)
        strategy.asset_class_focus = map_multi_values(row["Asset Class Focus"]) { |value| map_asset_class(value) }
        strategy.stage_focus = map_multi_values(row["Stage Focus"] || row["Stage focus"]) { |value| map_stage(value) }
        strategy.maturity_focus = map_multi_values(row["Maturity Focus"] || row["Maturity focus"]) { |value| map_maturity(value) }
        strategy.sector_investment_focus = map_multi_values(row["Sector Focus"] || row["Sector focus"]) { |value| map_sector(value) }
        strategy.keywords = split_list(row["Keywords"])
        strategy.min_check_size = to_decimal(row["Min Ticket Size"])
        strategy.max_check_size = to_decimal(row["Max Ticket Size"])
        strategy.country_headquarter_id = resolve_country_headquarter_id(
          country_value: row["Country Headquater"],
          region_ids: region_focus_ids
        )
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

        resolve_country_focus_ids(
          country_value: row["Country Headquater"],
          region_ids: region_focus_ids
        ).each do |country_id|
          focus = InvestmentStrategyCountryFocus.find_or_initialize_by(
            investment_strategy_id: strategy.id,
            country_id: country_id
          )
          save_record(focus, :investment_strategy_country_focus)
        end
      end
    end

    def import_investment_vehicles_and_links(workbook)
      each_row(workbook, "Investment Vehicles") do |row|
        vehicle_id = row["ID"].to_s.strip
        external_investor_id = row["Investor"].to_s.strip
        strategy_id = row["Investment Strategy"].to_s.strip
        next if vehicle_id.blank? || external_investor_id.blank?

        investor_id = @external_investor_to_uuid[external_investor_id]
        next unless investor_id.present?

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

    def import_contacts(workbook)
      each_row(workbook, "Contacts") do |row|
        contact_id = row["Contact ID"].to_s.strip
        external_investor_id = row["Investor ID"].to_s.strip
        next if contact_id.blank? || external_investor_id.blank?

        investor_id = @external_investor_to_uuid[external_investor_id]
        next unless investor_id.present?

        first_name, last_name = split_name(row["Contact Name"])
        contact = InvestorContact.find_or_initialize_by(id: contact_id)
        contact.investor_id = investor_id
        contact.first_name = first_name
        contact.last_name = last_name
        contact.email = row["Contact Email"].to_s.strip.presence
        contact.linked_in_id = row["Contact Linkedin"].to_s.strip.presence
        contact.created_by_id ||= @user_id
        contact.updated_by_id = @user_id if contact.respond_to?(:updated_by_id=)
        contact.created_at_utc ||= Time.current.utc
        contact.updated_at_utc = Time.current.utc if contact.respond_to?(:updated_at_utc=)
        save_record(contact, :investor_contacts)
      end
    end

    def import_proof_ledgers(workbook)
      each_row(workbook, "Proof Ledger") do |row|
        external_investor_id = row["Investor ID"].to_s.strip
        investor_id = @external_investor_to_uuid[external_investor_id]
        vehicle_id = row["Investment Vehicle ID"].to_s.strip.presence
        strategy_id = row["Investment Strategy ID"].to_s.strip.presence
        base_id = row["Proof Ledger ID"].to_s.strip.presence

        next unless investor_id.present?

        PROOF_FIELD_MAP.each do |label, field_id|
          type_val = row["Proof Ledger - #{label} - Type"]
          certainty = row["Proof Ledger - #{label} - Certainty %"]
          rationale = row["Proof Ledger - #{label} - Rationale"]
          next if [type_val, certainty, rationale].all?(&:blank?)

          reference_url = extract_url(row["Proof Ledger - #{label} - Rationale"])

          proof = ProofLedger.new(
            id: SecureRandom.uuid,
            investor_id: investor_id,
            investment_vehicle_id: vehicle_id,
            investment_strategy_id: strategy_id,
            field_id: field_id,
            proof_type: map_proof_type(type_val),
            criteria_name: label,
            criteria_value_old: nil,
            criteria_value_new: nil,
            proof_text: rationale.to_s.strip.presence,
            certainty_score: to_decimal(certainty),
            status: "active",
            version: 0,
            source_name: row["Proof Miner"].to_s.strip.presence,
            reference: reference_url,
            data_project_id: base_id,
            rational: rationale.to_s.strip.presence,
            created_by_id: @user_id,
            created_at_utc: Time.current.utc
          )
          save_record(proof, :proof_ledgers)
        end
      end
    end

    def each_row(workbook, sheet_name)
      sheet = workbook.sheet(sheet_name)
      headers = sheet.row(1).map { |h| h.to_s.strip }
      2.upto(sheet.last_row) do |index|
        values = sheet.row(index)
        row = headers.each_with_index.each_with_object({}) do |(header, i), memo|
          memo[header] = values[i]
        end
        yield row
      rescue StandardError => e
        @errors << "#{sheet_name} row #{index}: #{e.message}"
      end
    end

    def find_or_build_location(country_name:, region_name:, city:)
      country_id = country_id_by_name(country_name, region_name)
      return nil if country_id.blank?

      city_val = city.to_s.strip
      location = Location.find_or_initialize_by(
        country_id: country_id,
        city: city_val.presence
      )
      location.location_type ||= "primary"
      location.created_by_id ||= @user_id
      location.updated_by_id = @user_id if location.respond_to?(:updated_by_id=)
      location.created_at_utc ||= Time.current.utc
      location.updated_at_utc = Time.current.utc if location.respond_to?(:updated_at_utc=)
      save_record(location, :locations)
      location
    end

    def investor_uuid_for_strategy(strategy_id)
      external = @strategy_to_external_investor[strategy_id]
      @external_investor_to_uuid[external]
    end

    def country_id_by_name(name, region_name = nil)
      key = normalize_key(name)
      return nil if key.blank?

      country = @countries_by_name[key]
      return country.id if country

      primary_region = split_region_values(region_name).first
      region_id = region_id_by_name(primary_region, allow_unknown: false) || region_id_by_name("Unknown")
      return nil if region_id.blank?

      country = Country.create!(
        region_id: region_id,
        name: name.to_s.strip,
        iso_code: fallback_code(name, 2, "XX"),
        iso3code: fallback_code(name, 3, "XXX"),
        calling_code: "+0",
        created_at_utc: Time.current.utc
      )
      @countries_by_name[key] = country
      @country_ids_by_region_id[region_id] ||= []
      @country_ids_by_region_id[region_id] << country.id
      country.id
    end

    def region_id_by_name(name, allow_unknown: true)
      return nil if name.blank? && !allow_unknown

      key = normalize_key(name.presence || "Unknown")
      region = @regions_by_name[key]
      return region.id if region

      return nil if name.blank? && !allow_unknown

      region = Region.create!(
        name: name.presence || "Unknown",
        code: fallback_code(name.presence || "Unknown", 3, "UNK"),
        description: nil,
        created_at_utc: Time.current.utc
      )
      @regions_by_name[key] = region
      region.id
    end

    def currency_id(value)
      key = normalize_key(value)
      return nil if key.blank?

      @currencies_by_code[key]&.id || @currencies_by_name[key]&.id
    end

    def map_investor_type(value)
      norm = normalize_enum_value(value)
      mapping = {
        "fund_of_funds" => "fund_of_funds",
        "fund_of_fund" => "fund_of_funds",
        "family_office" => "family_office",
        "multi_family_office" => "multi_family_office",
        "institutional_investor" => "institutional_investor"
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

    def map_asset_class(value)
      norm = normalize_enum_value(value)
      mapping = {
        "debt_venture" => "debt_general",
        "debt_private" => "debt_general",
        "debt" => "debt_general",
        "funds_vc" => "funds_vc",
        "fund_vc" => "funds_vc",
        "funds_pe" => "funds_general",
        "funds_general" => "funds_general",
        "direct_general" => "direct_pe",
        "public_equity" => "public_stocks",
        "fund_of_funds" => "fund_of_funds_general",
        "fund_of_funds_general" => "fund_of_funds_general",
        "fund_of_funds_vc" => "fund_of_funds_vc"
      }
      mapped = mapping[norm] || norm
      InvestmentStrategy::ASSET_CLASS_FOCUS_VALUES.include?(mapped) ? mapped : nil
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

    def map_maturity(value)
      norm = normalize_enum_value(value)
      mapped = {
        "mature" => "established",
        "early" => "developing"
      }[norm] || norm
      InvestmentStrategy::MATURITY_FOCUS_VALUES.include?(mapped) ? mapped : nil
    end

    def map_simple_enum(value, allowed_values)
      norm = normalize_enum_value(value)
      allowed_values.include?(norm) ? norm : nil
    end

    def map_proof_type(value)
      norm = normalize_enum_value(value)
      allowed = ProofLedger.proof_types.keys
      return norm if allowed.include?(norm)
      return "manual" if norm.blank?

      "manual"
    end

    def split_name(value)
      parts = value.to_s.strip.split(/\s+/)
      return [nil, nil] if parts.empty?
      return [parts.first, nil] if parts.length == 1

      [parts.first, parts[1..].join(" ")]
    end

    def split_list(value)
      return [] if value.blank?

      value.to_s.split(/[,\n;]/).map(&:strip).reject(&:blank?)
    end

    def compact_array(value)
      Array(value).flatten.compact.reject(&:blank?).uniq
    end

    def map_multi_values(value)
      items = split_list(value)
      items = [value] if items.empty? && value.present?
      compact_array(items.map { |item| yield(item) })
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

    def normalize_key(value)
      value.to_s.strip.downcase
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

    def fallback_code(value, length, default)
      cleaned = value.to_s.gsub(/[^A-Za-z]/, "").upcase
      return default if cleaned.blank?

      cleaned.first(length).ljust(length, "X")
    end

    def split_region_values(value)
      split_list(value).map(&:strip).reject(&:blank?).uniq
    end

    def resolve_region_focus_ids(region_value:, country_value:)
      region_ids = split_region_values(region_value).filter_map do |region_name|
        region_id_by_name(region_name, allow_unknown: false)
      end
      return region_ids.uniq if region_ids.any?

      country = @countries_by_name[normalize_key(country_value)]
      return [] unless country&.region_id

      [country.region_id]
    end

    def resolve_country_headquarter_id(country_value:, region_ids:)
      primary_region_name = region_name_by_id(region_ids.first)
      country_id = country_id_by_name(country_value, primary_region_name)
      return country_id if country_id.present?

      return nil if region_ids.blank?

      @country_ids_by_region_id[region_ids.first]&.first
    end

    def resolve_country_focus_ids(country_value:, region_ids:)
      country_id = resolve_country_headquarter_id(country_value: country_value, region_ids: region_ids)
      return [country_id] if country_id.present?
      return [] if region_ids.blank?

      region_ids.flat_map { |region_id| @country_ids_by_region_id[region_id] || [] }.uniq
    end

    def region_name_by_id(region_id)
      return nil if region_id.blank?

      @regions_by_id[region_id]&.name
    end

    def extract_url(value)
      text = value.to_s
      match = text.match(%r{https?://[^\s\)]+}i)
      match&.[](0)
    end

    def to_decimal(value)
      return nil if value.blank?
      return value if value.is_a?(BigDecimal)

      cleaned = value.to_s.gsub(/[^\d\.\-]/, "")
      return nil if cleaned.blank?

      BigDecimal(cleaned)
    rescue ArgumentError
      nil
    end

    def to_integer(value)
      return value.to_i if value.is_a?(Numeric)
      return nil if value.blank?

      value.to_s[/\d+/]&.to_i
    end

    def to_time(value)
      return nil if value.blank?
      return value if value.is_a?(Time) || value.is_a?(DateTime)

      Time.zone.parse(value.to_s)
    rescue ArgumentError, TypeError
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

    def print_summary
      @logger.puts "\nImport finished#{@dry_run ? ' (DRY RUN)' : ''}"
      @stats.keys.sort.each { |key| @logger.puts " - #{key}: #{@stats[key]}" }
      if @errors.any?
        @logger.puts "\nErrors (#{@errors.size}):"
        @errors.first(100).each { |error| @logger.puts " - #{error}" }
        @logger.puts " - ...and #{@errors.size - 100} more" if @errors.size > 100
      end
    end
  end
end
