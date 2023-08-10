# frozen_string_literal: true

module Concerns
  module FactoryBuilder
    def attribute_factory(name, params)
      "add_attribute(:#{name}) { #{factory_for_attribute name, params} }"
    end

    def noop_attribute_factory(name, params)
      "add_attribute(:#{name}) { #{factory_from_attribute_default params} }"
    end

    private

    def factory_for_attribute(name, params)
      column = params[:column]
      validators = params[:validators]

      literal_value = factory_from_attribute_validation column, validators
      return literal_value unless literal_value.nil?

      # TODO(stefan): add support for generating factories based on validators.
      # Like we do for text attributes in factory_for_text_attribute.
      case column.type
      when :string, :text, :citext
        factory_for_text_attribute name, params
      when :datetime
        'DateTime.now'
      when :date
        'Date.today'
      when :integer
        'Faker::Number.number'
      when :boolean
        'Faker::Boolean.boolean'
      when :json, :jsonb
        'JSON.parse Faker::Json.shallow_json'
      else
        debug "factory_for_attribute - unsupported column type: '#{column.type}' for #{model_class_name}.#{name}"
      end
    end

    def factory_for_text_attribute(name, params)
      len = text_attribute_length(params)
      unique = ActiveRecord::Base.connection.indexes(table_name).any? do |idx|
        idx.columns.include?(name) && idx.unique
      end
      modifier = '.unique' if unique

      case name
      when /email/
        "Faker::Internet#{modifier}.email"
      when /phone/
        unique ? "Faker::PhoneNumber#{modifier}.cell_phone_in_e164" : "'+233200123456'"
      when /name/
        factory_for_name_attribute name
      when /url/
        'Faker::Internet.url'
      else
        "Faker::String.random(length: #{len})"
      end
    end

    def factory_for_name_attribute(name)
      case name
      when /user/
        "Faker::Internet#{modifier}.username(specifier: #{len})"
      when /first/
        'Faker::Name.first_name'
      when /last/, /other/, /middle/
        'Faker::Name.last_name'
      else
        'Faker::Name.name'
      end
    end

    # rubocop:disable Metrics/AbcSize
    def factory_from_attribute_validation(column, validators)
      if validators.key? :inclusion
        "#{serialize_enumerable validators[:inclusion][:in]}.sample"
      elsif validators.key? :numericality
        validator = validators[:numericality]

        return serialize_number(validator[:equal_to]) if validator[:equal_to].present?

        if validator[:other_than].present?
          debug 'We currently cannot guarantee factories when `other_than`` is used on `numericality` validations'
        end

        min = nil
        if validator[:greater_than].present?
          min = validator[:greater_than] + 1
        elsif validator[:greater_than_or_equal_to].present?
          min = validator[:greater_than_or_equal_to]
        end

        max = 100
        if validator[:less_than].present?
          max = validator[:less_than] - 1
        elsif validator[:less_than_or_equal_to].present?
          max = validator[:less_than_or_equal_to]
        end

        "rand(#{serialize_number min}..#{serialize_number max})"
      end
    rescue RangeError => e
      debug "We cannot guarantee that the factory attribute for #{model_class}.#{column.name} will be valid " \
                  "due to an error retrieving the `inclusion` values:\n#{e}"
    end
    # rubocop:enable Metrics/AbcSize

    def factory_from_attribute_default(params)
      column = params[:column]

      return 'nil' unless column.has_default?

      case column.type
      when :string, :text, :citext
        serialize_string column.default
      # when :datetime
      #   'DateTime.now'
      # when :date
      #   'Date.today'
      when :integer
        serialize_number column.default
      when :boolean
        column.default
      when :json, :jsonb
        JSON.parse column.default
      else
        debug "factory_from_attribute_default - unsupported column type: '#{column.type}' for #{model_class_name}.#{name}"
      end
    end

    def text_attribute_length(params)
      is_len = params[:validators].dig(:length, :is)
      min_len = params[:validators].dig(:length, :minimum)
      max_len = params[:validators].dig(:length, :maximum)
      col_limit = params[:column].limit

      min = [is_len, min_len, 0].compact.first
      max = [is_len, max_len, col_limit, 50].compact.first

      min == max ? max : Range.new(min, max)
    end
  end
end
