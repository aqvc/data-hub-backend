class ConvertStrategyFocusColumnsToPgEnums < ActiveRecord::Migration[7.0]
  ASSET_CLASS_VALUES = %w[
    agriculture art_and_antiques buyout crypto debt_general debt_special_situations
    direct_distressed direct_pe direct_restructuring direct_vc fixed_income
    fund_of_funds_general fund_of_funds_pe fund_of_funds_vc funds_general funds_vc
    hedge_fund infrastructure ip_rights mezzanine other public_stocks real_estate
    real_estate_debt
  ].freeze

  SECTOR_VALUES = %w[
    ad_tech aerospace ag_tech agnostic artificial_intelligence arvr auto_tech
    b2b_enterprise_saa_s b2b_payments big_data bio_tech blockchain_and_web3 climate_tech
    consumer_tech cybersecurity deep_tech defence_tech digital_health ed_tech energy_tech
    environment fem_tech fin_tech food_tech gaming health_tech hospitality_tech hr_tech
    impact_investing industrial_tech infrastructure_software insure_tech internet_of_things
    legal_tech life_sciences logistics_tech manufacturing maritime_and_defense
    maritime_and_defense_tech marketing_tech marketplaces mobile mobility_tech
    oil_gas_and_mining open_source_software other process_automation prop_tech retail
    robotics saa_s software_as_a_service space_tech sports_tech
    technology_media_and_telecommunications transportation_and_logistics_tech
    travel_and_hospitality_tech
  ].freeze

  MATURITY_VALUES = %w[developing emerging established].freeze
  STAGE_VALUES = %w[pre_seed seed series_a series_b series_c series_c_plus].freeze

  def up
    create_enum_type("asset_class", ASSET_CLASS_VALUES)
    create_enum_type("sector", SECTOR_VALUES)
    create_enum_type("maturity", MATURITY_VALUES)
    create_enum_type("stage", STAGE_VALUES)

    normalize_asset_class_focus!
    normalize_sector_focus!
    normalize_maturity_focus!
    normalize_stage_focus!

    execute <<~SQL
      ALTER TABLE public.investment_strategies
      ALTER COLUMN asset_class_focus DROP DEFAULT,
      ALTER COLUMN sector_investment_focus DROP DEFAULT,
      ALTER COLUMN maturity_focus DROP DEFAULT,
      ALTER COLUMN stage_focus DROP DEFAULT,
      ALTER COLUMN asset_class_focus TYPE asset_class[]
        USING COALESCE(asset_class_focus, ARRAY[]::varchar[])::asset_class[],
      ALTER COLUMN sector_investment_focus TYPE sector[]
        USING COALESCE(sector_investment_focus, ARRAY[]::varchar[])::sector[],
      ALTER COLUMN maturity_focus TYPE maturity[]
        USING COALESCE(maturity_focus, ARRAY[]::varchar[])::maturity[],
      ALTER COLUMN stage_focus TYPE stage[]
        USING COALESCE(stage_focus, ARRAY[]::varchar[])::stage[];
    SQL

    execute <<~SQL
      ALTER TABLE public.investment_strategies
      ALTER COLUMN asset_class_focus SET DEFAULT ARRAY[]::asset_class[],
      ALTER COLUMN sector_investment_focus SET DEFAULT ARRAY[]::sector[],
      ALTER COLUMN maturity_focus SET DEFAULT ARRAY[]::maturity[],
      ALTER COLUMN stage_focus SET DEFAULT ARRAY[]::stage[];
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE public.investment_strategies
      ALTER COLUMN asset_class_focus TYPE varchar[]
        USING COALESCE(asset_class_focus::text[], ARRAY[]::text[])::varchar[],
      ALTER COLUMN asset_class_focus SET DEFAULT ARRAY[]::varchar[],
      ALTER COLUMN sector_investment_focus TYPE varchar[]
        USING COALESCE(sector_investment_focus::text[], ARRAY[]::text[])::varchar[],
      ALTER COLUMN sector_investment_focus SET DEFAULT ARRAY[]::varchar[],
      ALTER COLUMN maturity_focus TYPE varchar[]
        USING COALESCE(maturity_focus::text[], ARRAY[]::text[])::varchar[],
      ALTER COLUMN maturity_focus SET DEFAULT ARRAY[]::varchar[],
      ALTER COLUMN stage_focus TYPE varchar[]
        USING COALESCE(stage_focus::text[], ARRAY[]::text[])::varchar[],
      ALTER COLUMN stage_focus SET DEFAULT ARRAY[]::varchar[];
    SQL

    drop_enum_type("stage")
    drop_enum_type("maturity")
    drop_enum_type("sector")
    drop_enum_type("asset_class")
  end

  private

  def create_enum_type(name, values)
    quoted_values = values.map { |value| quote(value) }.join(", ")
    execute <<~SQL
      DO $$
      BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = '#{name}') THEN
          CREATE TYPE #{name} AS ENUM (#{quoted_values});
        END IF;
      END
      $$;
    SQL
  end

  def drop_enum_type(name)
    execute "DROP TYPE IF EXISTS #{name};"
  end

  def normalize_asset_class_focus!
    allowed = quoted_array(ASSET_CLASS_VALUES)
    execute <<~SQL
      UPDATE public.investment_strategies
      SET asset_class_focus = COALESCE((
        SELECT array_agg(mapped ORDER BY ord)
        FROM (
          SELECT
            CASE lower(value)
              WHEN 'debt_venture' THEN 'debt_general'
              WHEN 'debt_private' THEN 'debt_general'
              WHEN 'debt' THEN 'debt_general'
              WHEN 'funds_pe' THEN 'funds_general'
              WHEN 'fund_vc' THEN 'funds_vc'
              WHEN 'direct_general' THEN 'direct_pe'
              WHEN 'public_equity' THEN 'public_stocks'
              WHEN 'fund_of_funds' THEN 'fund_of_funds_general'
              ELSE lower(value)
            END AS mapped,
            ord
          FROM unnest(COALESCE(asset_class_focus, ARRAY[]::varchar[])) WITH ORDINALITY AS u(value, ord)
        ) normalized
        WHERE mapped = ANY(#{allowed})
      ), ARRAY[]::varchar[]);
    SQL
  end

  def normalize_sector_focus!
    allowed = quoted_array(SECTOR_VALUES)
    execute <<~SQL
      UPDATE public.investment_strategies
      SET sector_investment_focus = COALESCE((
        SELECT array_agg(mapped ORDER BY ord)
        FROM (
          SELECT
            CASE lower(value)
              WHEN 'technology' THEN 'technology_media_and_telecommunications'
              WHEN 'software_as_a_service_saa_s' THEN 'software_as_a_service'
              WHEN 'saas' THEN 'saa_s'
              WHEN 'web3' THEN 'blockchain_and_web3'
              WHEN 'blockchain' THEN 'blockchain_and_web3'
              WHEN 'healthcare' THEN 'health_tech'
              ELSE lower(value)
            END AS mapped,
            ord
          FROM unnest(COALESCE(sector_investment_focus, ARRAY[]::varchar[])) WITH ORDINALITY AS u(value, ord)
        ) normalized
        WHERE mapped = ANY(#{allowed})
      ), ARRAY[]::varchar[]);
    SQL
  end

  def normalize_maturity_focus!
    allowed = quoted_array(MATURITY_VALUES)
    execute <<~SQL
      UPDATE public.investment_strategies
      SET maturity_focus = COALESCE((
        SELECT array_agg(mapped ORDER BY ord)
        FROM (
          SELECT
            CASE lower(value)
              WHEN 'mature' THEN 'established'
              WHEN 'early' THEN 'developing'
              ELSE lower(value)
            END AS mapped,
            ord
          FROM unnest(COALESCE(maturity_focus, ARRAY[]::varchar[])) WITH ORDINALITY AS u(value, ord)
        ) normalized
        WHERE mapped = ANY(#{allowed})
      ), ARRAY[]::varchar[]);
    SQL
  end

  def normalize_stage_focus!
    allowed = quoted_array(STAGE_VALUES)
    execute <<~SQL
      UPDATE public.investment_strategies
      SET stage_focus = COALESCE((
        SELECT array_agg(mapped ORDER BY ord)
        FROM (
          SELECT
            CASE lower(value)
              WHEN 'preseed' THEN 'pre_seed'
              WHEN 'seed_stage' THEN 'seed'
              WHEN 'series_c_' THEN 'series_c'
              ELSE lower(value)
            END AS mapped,
            ord
          FROM unnest(COALESCE(stage_focus, ARRAY[]::varchar[])) WITH ORDINALITY AS u(value, ord)
        ) normalized
        WHERE mapped = ANY(#{allowed})
      ), ARRAY[]::varchar[]);
    SQL
  end

  def quoted_array(values)
    "ARRAY[#{values.map { |value| quote(value) }.join(', ')}]"
  end
end
