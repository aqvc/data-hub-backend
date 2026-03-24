class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Devise::Controllers::Helpers

  private

  def deep_camelize(value)
    case value
    when Array
      value.map { |v| deep_camelize(v) }
    when Hash
      value.each_with_object({}) do |(k, v), memo|
        memo[k.to_s.camelize(:lower)] = deep_camelize(v)
      end
    else
      value
    end
  end

  def extract_model_attributes(key)
    raw = params[key]
    return {} if raw.blank?

    hash = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
    hash.each_with_object({}) do |(k, v), memo|
      memo[k.to_s.underscore] = v
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

  def serialize_record(record)
    deep_camelize(record.attributes)
  end

  def render_problem(code:, detail:, type:, status:, errors: nil)
    payload = {
      title: code,
      detail: detail,
      type: type,
      status: status
    }
    payload[:errors] = errors if errors.present?
    render json: payload, status: status
  end
end
