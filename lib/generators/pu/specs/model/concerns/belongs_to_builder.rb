# frozen_string_literal: true

module Concerns
  module BelongsToBuilder
    def all_belongs_to
      @all_belongs_to ||= model_class.reflect_on_all_associations(:belongs_to).each_with_object({}.with_indifferent_access) do |assoc, hash|
        hash.merge! build_belongs_to(assoc)
      end
    end

    def belongs_to
      @belongs_to ||= all_belongs_to.reject do |_name, params|
        params[:association].options[:polymorphic]
      end
    end

    def required_belongs_to
      @required_belongs_to ||= belongs_to.reject do |_name, params|
        params[:association].options[:optional]
      end
    end

    def optional_belongs_to
      @optional_belongs_to ||= belongs_to.select do |_name, params|
        params[:association].options[:optional]
      end
    end

    def polymorphic_belongs_to
      @polymorphic_belongs_to ||= model_class.reflect_on_all_associations(:belongs_to).each_with_object([]) do |assoc, array|
        next unless assoc.options[:polymorphic]

        array << assoc.name
      end
    end

    private

    def build_belongs_to(association)
      validate_association association

      {
        association.name =>
        {
          association:
        }
      }
    end
  end
end
