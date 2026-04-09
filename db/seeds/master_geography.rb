module Seeds
  module MasterGeography
    module_function

    def seed!
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

      country_names.each do |name|
        key = normalize.call(name)
        next if countries_by_key[key]

        country = Country.create!(
          region_id: global_region.id,
          name: name,
          iso_code: name.gsub(/[^A-Za-z]/, "").upcase.first(2).ljust(2, "X"),
          iso3code: name.gsub(/[^A-Za-z]/, "").upcase.first(3).ljust(3, "X"),
          calling_code: "+0",
          created_at_utc: now
        )
        countries_by_key[key] = country
        created += 1
      end

      {
        regions_total: Region.count,
        countries_total: Country.count,
        countries_created: created,
        has_zimbabwe: Country.exists?("LOWER(name) = 'zimbabwe'")
      }
    end
  end
end
