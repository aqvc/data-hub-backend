module GraphqlSupport
  module PayloadHelpers
    private

    def deep_camelize(value)
      case value
      when Array
        value.map { |item| deep_camelize(item) }
      when Hash
        value.each_with_object({}) do |(key, item), memo|
          memo[key.to_s.camelize(:lower)] = deep_camelize(item)
        end
      else
        value
      end
    end

    def serialize_record(record)
      deep_camelize(record.attributes)
    end

    def extract_model_attributes(raw)
      return {} if raw.blank?

      hash =
        if raw.respond_to?(:to_unsafe_h)
          raw.to_unsafe_h
        elsif raw.respond_to?(:to_h)
          raw.to_h
        else
          raw
        end
      hash.each_with_object({}) do |(key, value), memo|
        memo[key.to_s.underscore] = value
      end
    end

    def assign_filtered_attributes(record, attrs)
      attrs.each do |column, value|
        next unless record.class.column_names.include?(column.to_s)

        record[column] = normalize_attribute_value(record, column.to_s, value)
      end
    end

    def normalize_attribute_value(record, column_name, value)
      return value unless value.is_a?(String) && value.strip.empty?

      column = record.class.columns_hash[column_name]
      return value if column.nil?

      case column.type
      when :string, :text
        value
      else
        nil
      end
    end
  end
end
