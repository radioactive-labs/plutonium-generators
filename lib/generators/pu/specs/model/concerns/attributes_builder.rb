# frozen_string_literal: true

module Concerns
  module AttributesBuilder
    # rubocop:disable Metrics/AbcSize
    def model_attributes
      @model_attributes ||= begin
        foreign_keys = model_class.reflect_on_all_associations(:belongs_to).map(&:foreign_key)
        polymorphic_types_fields = model_class.reflect_on_all_associations(:belongs_to).each_with_object([]) do |assoc, array|
          next unless assoc.options[:polymorphic]

          array << "#{assoc.name}_type"
        end

        attributes = model_class.attribute_names - (foreign_keys + %w[id created_at
                                                                      updated_at]) - polymorphic_types_fields

        attributes.each_with_object({}.with_indifferent_access) do |attribute_name, hash|
          hash.merge! build_attribute(attribute_name)
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    def required_model_attributes
      @required_model_attributes = model_attributes.select do |_name, params|
        attribute_required?(params)
      end
    end

    def optional_model_attributes
      @optional_model_attributes = model_attributes.reject do |_name, params|
        attribute_required?(params)
      end
    end

    private

    def build_attribute(attribute_name)
      column = model_class.column_for_attribute(attribute_name)
      attribute_name_key = attribute_name.sub('_digest', '')
      validators = model_class.validators_on(attribute_name_key).each_with_object({}) do |v, hash|
        hash[v.kind] = v.options
      end

      {
        attribute_name_key => {
          column:,
          validators:
        }
      }
    end

    def attribute_required?(params)
      return false if params[:column].has_default?

      validators = params[:validators]
      return true if validators.key?(:presence)

      validators.dig(:length, :is).present? && \
        !(validators.dig(:length, :allow_nil) || validators.dig(:length, :allow_blank))
    end
  end
end
