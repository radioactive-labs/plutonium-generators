# frozen_string_literal: true

module Concerns
  module ValidationsBuilder
    def attribute_validations
      @attribute_validations ||= model_attributes.each_with_object([]) do |attr, obj|
        name = attr[0]
        params = attr[1]

        params[:validators].each do |validator, options|
          matcher = shoulda_matcher_for name, validator, options
          next if matcher.nil?

          obj << "it { should #{matcher} }"
        end
      end
    end

    def belongs_to_validations
      @belongs_to_validations ||= all_belongs_to.each_with_object([]) do |attr, obj|
        name = attr[0]
        params = attr[1]

        obj << "it { should belong_to(:#{name})#{belongs_to_validation_modifiers(params[:association])} }"
      end
    end

    # rubocop:disable Naming/PredicateName
    def has_one_validations
      @has_one_validations ||= has_one.each_with_object([]) do |attr, obj|
        name = attr[0]
        params = attr[1]

        obj << "it { should have_one(:#{name})#{has_one_validation_modifiers(params[:association])} }"
      end
    end
    # rubocop:enable Naming/PredicateName

    # rubocop:disable Naming/PredicateName
    def has_many_validations
      @has_many_validations ||= has_many.each_with_object([]) do |attr, obj|
        name = attr[0]
        params = attr[1]

        obj << "it { should have_many(:#{name})#{has_many_validation_modifiers(params[:association])} }"
      end
    end
    # rubocop:enable Naming/PredicateName

    private

    # TODO: clean up this bloody mess
    # rubocop:disable Metrics/AbcSize, Metrics/BlockLength
    def shoulda_matcher_for(name, validator, options)
      matcher = case validator.to_sym
      when :presence
        "validate_presence_of(:#{name})"
      when :uniqueness
        "validate_uniqueness_of(:#{name})"
      when :length
        "validate_length_of(:#{name})"
      when :inclusion
        "validate_inclusion_of(:#{name})"
      when :numericality
        "validate_numericality_of(:#{name})"
      when :phone
        "allow_values('+233200123456', '0200123456').for(:#{name})"
      when :email
        "allow_values('email@domain.com', 'email+plusvalu@domain.com').for(:#{name})"
      else
        debug "Unsupported validator: '#{validator}' for #{model_class_name}.#{name}"
        return
      end

      options.each do |option, value|
        case option.to_sym
        when :on
          matcher = "#{matcher}.on(:#{value})"
        when :case_sensitive
          matcher = "#{matcher}.case_insensitive" unless value
        when :allow_blank, :allow_nil
          matcher = "#{matcher}.#{option}" if value
        when :minimum
          matcher = "#{matcher}.is_at_least(#{value})"
        when :maximum
          matcher = "#{matcher}.is_at_most(#{value})"
        when :is
          matcher = (validator == :numericality) ? "#{matcher}.is_in(#{value})" : "#{matcher}.is_equal_to(#{value})"
        when :message
          matcher = "#{matcher}.with_message(#{serialize_string value})"
        when :scope
          matcher = "#{matcher}.scoped_to(#{value})"
        when :only_integer
          matcher = "#{matcher}.only_integer" if value
        when :less_than, :less_than_or_equal_to, :equal_to, :greater_than, :greater_than_or_equal_to, :other_than
          matcher = "#{matcher}.is_#{option}(#{value})"
        when :even, :odd
          matcher = "#{matcher}.#{option}" if value
        when :in
          matcher = "#{matcher}.in_array(#{serialize_enumerable value})"
        when :if, :with, :unless
          # do nothing
        else
          debug "Unsupported validator option: '#{option}' for #{model_class_name}.#{name}: #{validator}"
        end
      end
      matcher
    end
    # rubocop:enable Metrics/AbcSize, Metrics/BlockLength

    # rubocop:disable Metrics/AbcSize
    def belongs_to_validation_modifiers(association)
      modifier = ""

      %i[primary_key foreign_key].each do |opt|
        value = association.options[opt]
        modifier = "#{modifier}.with_#{opt}(#{serialize_value value})" if value.present?
      end

      %i[class_name dependent counter_cache touch autosave inverse_of].each do |opt|
        value = association.options[opt]
        modifier = "#{modifier}.#{opt}(#{serialize_value value})" if value.present?
      end

      %i[optional required].each do |opt|
        value = association.options[opt]
        modifier = "#{modifier}.#{opt}" if value.present?
      end

      conditions = read_scope :belongs_to, :where, association.name
      modifier = "#{modifier}.conditions(#{conditions})" if conditions.present?

      order = read_scope :belongs_to, :order, association.name
      modifier = "#{modifier}.order(#{order})" if order.present?

      modifier
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Naming/PredicateName, Metrics/AbcSize
    def has_one_validation_modifiers(association)
      modifier = ""

      %i[primary_key foreign_key].each do |opt|
        value = association.options[opt]
        modifier = "#{modifier}.with_#{opt}(#{serialize_value value})" if value.present?
      end

      %i[class_name dependent through source validate autosave].each do |opt|
        value = association.options[opt]
        modifier = "#{modifier}.#{opt}(#{serialize_value value})" if value.present?
      end

      %i[required].each do |opt|
        value = association.options[opt]
        modifier = "#{modifier}.#{opt}" if value.present?
      end

      conditions = read_scope :has_one, :where, association.name
      modifier = "#{modifier}.conditions(#{conditions})" if conditions.present?

      order = read_scope :has_one, :order, association.name
      modifier = "#{modifier}.order(#{order})" if order.present?

      modifier
    end
    # rubocop:enable Naming/PredicateName, Metrics/AbcSize

    # rubocop:disable Naming/PredicateName, Metrics/AbcSize
    def has_many_validation_modifiers(association)
      modifier = ""

      %i[primary_key foreign_key].each do |opt|
        value = association.options[opt]
        modifier = "#{modifier}.with_#{opt}(#{serialize_value value})" if value.present?
      end

      %i[class_name dependent through source validate autosave index_errors inverse_of].each do |opt|
        value = association.options[opt]
        modifier = "#{modifier}.#{opt}(#{serialize_value value})" if value.present?
      end

      conditions = read_scope :has_many, :where, association.name
      modifier = "#{modifier}.conditions(#{conditions})" if conditions.present?

      order = read_scope :has_many, :order, association.name
      modifier = "#{modifier}.order(#{order})" if order.present?

      modifier
    end
    # rubocop:enable Naming/PredicateName, Metrics/AbcSize
  end
end
