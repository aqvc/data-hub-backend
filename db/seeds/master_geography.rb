module Seeds
  module MasterGeography
    module_function
    CITIES_CSV_PATH = Rails.root.join("db/seeds/data/world-cities.csv")
    COUNTRY_REGIONS_CSV_PATH = Rails.root.join("db/seeds/data/iso_country_regions.csv")
    COUNTRY_NAME_ALIASES = {
      "antigua" => "Antigua and Barbuda",
      "bolivia" => "Bolivia (Plurinational State of)",
      "british virgin islands" => "Virgin Islands, British",
      "brunei" => "Brunei Darussalam",
      "burma (myanmar)" => "Myanmar",
      "cape verde" => "Cabo Verde",
      "congo" => "Congo",
      "curacao" => "Curaçao",
      "czech republic" => "Czechia",
      "democratic republic of congo" => "Congo, The Democratic Republic of the",
      "democratic republic of the congo" => "Congo, The Democratic Republic of the",
      "east timor" => "Timor-Leste",
      "falkland islands" => "Falkland Islands (Malvinas)",
      "french-guiana" => "French Guiana",
      "ivory coast" => "Côte d'Ivoire",
      "laos" => "Lao People's Democratic Republic",
      "macedonia" => "North Macedonia",
      "micronesia" => "Micronesia (Federated States of)",
      "moldova" => "Moldova, Republic of",
      "north korea" => "Korea (Democratic People's Republic of)",
      "palestine" => "Palestine, State of",
      "russia" => "Russian Federation",
      "saint helena" => "Saint Helena, Ascension and Tristan da Cunha",
      "south korea" => "Korea, Republic of",
      "swaziland" => "Eswatini",
      "syria" => "Syrian Arab Republic",
      "taiwan" => "Taiwan, Province of China",
      "tanzania" => "Tanzania, United Republic of",
      "the gambia" => "Gambia",
      "united states old" => "United States",
      "united states virgin islands" => "Virgin Islands, U.S.",
      "venezuela" => "Venezuela (Bolivarian Republic of)",
      "vietnam" => "Viet Nam"
    }.freeze
    MANUAL_REGION_OVERRIDES = {
      "Armenia" => "Europe/Asia",
      "Azerbaijan" => "Europe/Asia",
      "Cyprus" => "Europe/Asia",
      "Georgia" => "Europe/Asia",
      "Kazakhstan" => "Europe/Asia",
      "Russia" => "Europe/Asia",
      "Turkey" => "Europe/Asia",
      "Israel" => "Middle East",
      "Palestine" => "Middle East"
    }.freeze

    def seed!
      require "csv"

      region_names = <<~REGIONS
        Asia
        Africa
        Europe
        Oceania
        Caribbean
        South America
        North America
        Middle East
        Eastern Europe
        Europe/Asia
        Global
        Asia/Pacific
      REGIONS
                     .lines
                     .map(&:strip)
                     .reject(&:blank?)

      country_names = <<~COUNTRIES
        Afghanistan
        Åland Islands
        Albania
        Algeria
        Andorra
        Angola
        Anguilla
        Antigua
        Antigua and Barbuda
        Argentina
        Armenia
        Aruba
        Australia
        Austria
        Azerbaijan
        Bahamas
        Bahrain
        Bangladesh
        Barbados
        Belarus
        Belgium
        Belize
        Benin
        Bermuda
        Bhutan
        Bolivia
        Bosnia and Herzegovina
        Botswana
        Brazil
        British Indian Ocean Territory
        British Virgin Islands
        Brunei
        Bulgaria
        Burkina Faso
        Burma (Myanmar)
        Burundi
        Cambodia
        Cameroon
        Canada
        Cape Verde
        Cayman Islands
        Central African Republic
        Chad
        Chile
        China
        Colombia
        Comoros
        Congo
        Cook Islands
        Costa Rica
        Côte d'Ivoire
        Croatia
        Cuba
        Curacao
        Cyprus
        Czech Republic
        Democratic Republic of Congo
        Democratic Republic of the Congo
        Denmark
        Djibouti
        Dominica
        Dominican Republic
        East Timor
        Ecuador
        Egypt
        El Salvador
        Equatorial Guinea
        Eritrea
        Estonia
        Ethiopia
        Falkland Islands
        Faroe Islands
        Federated States of Micronesia
        Fiji
        Finland
        France
        French-Guiana
        Gabon
        Georgia
        Germany
        Ghana
        Gibraltar
        Greece
        Greenland
        Grenada
        Guam
        Guatemala
        Guernsey
        Guinea
        Guinea-Bissau
        Guyana
        Haiti
        Honduras
        Hong Kong
        Hungary
        Iceland
        India
        Indonesia
        Iran
        Iraq
        Ireland
        Isle of Man
        Israel
        Italy
        Ivory Coast
        Jamaica
        Japan
        Jersey
        Jordan
        Kazakhstan
        Kenya
        Kiribati
        Kosovo
        Kuwait
        Kyrgyzstan
        Laos
        Latvia
        Lebanon
        Lesotho
        Liberia
        Libya
        Liechtenstein
        Lithuania
        Luxembourg
        Macedonia
        Madagascar
        Malawi
        Malaysia
        Maldives
        Mali
        Malta
        Marshall Islands
        Martinique
        Mauritania
        Mauritius
        Mexico
        Micronesia
        Moldova
        Monaco
        Mongolia
        Montenegro
        Montserrat
        Morocco
        Mozambique
        Myanmar
        Namibia
        Nauru
        Nepal
        Netherlands
        New Caledonia
        New Zealand
        Nicaragua
        Niger
        Nigeria
        Niue
        North Korea
        North Macedonia
        Northern Mariana Islands
        Norway
        Oman
        Pakistan
        Palau
        Palestine
        Panama
        Papua New Guinea
        Paraguay
        Peru
        Philippines
        Pitcairn Islands
        Poland
        Portugal
        Puerto Rico
        Qatar
        Réunion
        Romania
        Russia
        Rwanda
        Saint Helena
        Saint Kitts and Nevis
        Saint Lucia
        Saint Vincent and the Grenadines
        Samoa
        San Marino
        São Tomé and Príncipe
        Saudi Arabia
        Senegal
        Serbia
        Seychelles
        Sierra Leone
        Singapore
        Sint Maarten
        Slovakia
        Slovenia
        Solomon Islands
        Somalia
        South Africa
        South Korea
        Spain
        Sri Lanka
        Sudan
        Suriname
        Swaziland
        Sweden
        Switzerland
        Syria
        Taiwan
        Tajikistan
        Tanzania
        Thailand
        The Gambia
        Timor-Leste
        Togo
        Tokelau
        Tonga
        Trinidad and Tobago
        Tunisia
        Turkey
        Turkmenistan
        Turks and Caicos
        Tuvalu
        Uganda
        Ukraine
        United Arab Emirates
        United Kingdom
        United States
        United States Old
        United States Virgin Islands
        Uruguay
        Uzbekistan
        Vanuatu
        Venezuela
        Vietnam
        Western Sahara
        Yemen
        Zambia
        Zimbabwe
      COUNTRIES
                      .lines
                      .map(&:strip)
                      .reject(&:blank?)

      normalize = ->(value) { value.to_s.strip.downcase }
      now = Time.current.utc
      country_reference_index = load_country_reference_index

      regions_by_key = Region.all.index_by { |region| normalize.call(region.name) }
      region_names.each do |name|
        key = normalize.call(name)
        next if regions_by_key[key]

        region = Region.create!(
          name: name,
          code: name.gsub(/[^A-Za-z]/, "").upcase.first(3).ljust(3, "X"),
          description: nil,
          created_at_utc: now
        )
        regions_by_key[key] = region
      end

      global_region = regions_by_key[normalize.call("Global")] || regions_by_key.values.first
      countries_by_key = Country.all.index_by { |country| normalize.call(country.name) }
      created = 0
      updated = 0

      country_names.each do |name|
        key = normalize.call(name)
        reference = country_reference_for(name: name, country_reference_index: country_reference_index)
        mapped_region_name = canonical_region_name_for_reference(country_name: name, reference: reference)
        mapped_region = regions_by_key[normalize.call(mapped_region_name)] if mapped_region_name.present?

        desired_iso2 = reference&.fetch("alpha-2", nil).presence || name.gsub(/[^A-Za-z]/, "").upcase.first(2).ljust(2, "X")
        desired_iso3 = reference&.fetch("alpha-3", nil).presence || name.gsub(/[^A-Za-z]/, "").upcase.first(3).ljust(3, "X")

        country = countries_by_key[key]
        if country.nil?
          country = Country.create!(
            region_id: mapped_region&.id || global_region.id,
            name: name,
            iso_code: desired_iso2,
            iso3code: desired_iso3,
            calling_code: "+0",
            created_at_utc: now
          )
          countries_by_key[key] = country
          created += 1
          next
        end

        has_changes = false
        if mapped_region.present? && country.region_id.to_s != mapped_region.id.to_s
          country.region_id = mapped_region.id
          has_changes = true
        end
        if country.iso_code.to_s != desired_iso2.to_s
          country.iso_code = desired_iso2
          has_changes = true
        end
        if country.iso3code.to_s != desired_iso3.to_s
          country.iso3code = desired_iso3
          has_changes = true
        end

        if has_changes
          country.updated_at_utc = now if country.respond_to?(:updated_at_utc=)
          country.save!
          updated += 1
        end
      end

      city_stats = import_cities_from_csv!(countries_by_key: countries_by_key, now: now)

      {
        regions_total: Region.count,
        countries_total: Country.count,
        countries_created: created,
        countries_updated: updated,
        cities_total: City.count,
        cities_created: city_stats[:cities_created],
        cities_rows_processed: city_stats[:rows_processed],
        cities_skipped_blank: city_stats[:rows_skipped_blank],
        cities_skipped_unknown_country: city_stats[:rows_skipped_unknown_country],
        has_zimbabwe: Country.exists?("LOWER(name) = 'zimbabwe'")
      }
    end

    def load_country_reference_index
      return {} unless File.exist?(COUNTRY_REGIONS_CSV_PATH)

      CSV.foreach(COUNTRY_REGIONS_CSV_PATH, headers: true).each_with_object({}) do |row, memo|
        next if row.nil?

        payload = row.to_h
        name_key = normalize_country_lookup_key(payload["name"])
        iso2_key = normalize_country_lookup_key(payload["alpha-2"])
        iso3_key = normalize_country_lookup_key(payload["alpha-3"])

        memo[name_key] = payload if name_key.present?
        memo[iso2_key] = payload if iso2_key.present?
        memo[iso3_key] = payload if iso3_key.present?
      end
    end

    def country_reference_for(name:, country_reference_index:)
      alias_name = COUNTRY_NAME_ALIASES[name.to_s.strip.downcase] || name
      key = normalize_country_lookup_key(alias_name)
      country_reference_index[key]
    end

    def normalize_country_lookup_key(value)
      I18n.transliterate(value.to_s)
          .downcase
          .gsub(/[^a-z0-9]+/, " ")
          .strip
    end

    def canonical_region_name_for_reference(country_name:, reference:)
      return MANUAL_REGION_OVERRIDES[country_name] if MANUAL_REGION_OVERRIDES[country_name].present?
      return nil if reference.blank?

      region = reference["region"].to_s.strip
      sub_region = reference["sub-region"].to_s.strip
      intermediate = reference["intermediate-region"].to_s.strip

      case region
      when "Africa"
        "Africa"
      when "Europe"
        sub_region == "Eastern Europe" ? "Eastern Europe" : "Europe"
      when "Asia"
        sub_region == "Western Asia" ? "Middle East" : "Asia"
      when "Oceania"
        "Oceania"
      when "Americas"
        return "Caribbean" if intermediate == "Caribbean"
        return "South America" if intermediate == "South America"

        "North America"
      else
        nil
      end
    end

    def import_cities_from_csv!(countries_by_key:, now:)
      return {
        cities_created: 0,
        rows_processed: 0,
        rows_skipped_blank: 0,
        rows_skipped_unknown_country: 0
      } unless File.exist?(CITIES_CSV_PATH)

      normalize = ->(value) { value.to_s.strip.downcase }
      existing_pairs = City.pluck(:country_id, :name).each_with_object({}) do |(country_id, name), memo|
        next if country_id.blank? || name.blank?

        memo["#{country_id}:#{name.strip.downcase}"] = true
      end

      created = 0
      rows_processed = 0
      skipped_blank = 0
      skipped_unknown_country = 0

      CSV.foreach(CITIES_CSV_PATH, headers: true) do |row|
        rows_processed += 1
        city_name = row["name"].to_s.strip
        country_name = row["country"].to_s.strip
        if city_name.blank? || country_name.blank?
          skipped_blank += 1
          next
        end

        country = countries_by_key[normalize.call(country_name)]
        if country.nil?
          skipped_unknown_country += 1
          next
        end

        key = "#{country.id}:#{city_name.downcase}"
        next if existing_pairs[key]

        City.create!(
          country_id: country.id,
          name: city_name,
          created_at_utc: now,
          updated_at_utc: now
        )
        existing_pairs[key] = true
        created += 1
      end

      {
        cities_created: created,
        rows_processed: rows_processed,
        rows_skipped_blank: skipped_blank,
        rows_skipped_unknown_country: skipped_unknown_country
      }
    end
  end
end
