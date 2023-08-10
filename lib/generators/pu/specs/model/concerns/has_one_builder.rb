# frozen_string_literal: true

module Concerns
  module HasOneBuilder
    # rubocop:disable Naming/PredicateName
    def has_one
      @has_one ||= model_class.reflect_on_all_associations(:has_one).each_with_object({}.with_indifferent_access) do |assoc, hash|
        hash.merge! build_has_one(assoc)
      end
    end
    # rubocop:enable Naming/PredicateName

    def required_has_one
      @required_has_one ||= has_one.select do |_name, params|
        params[:association].options[:required]
      end
    end

    def optional_has_one
      @optional_has_one ||= has_one.reject do |_name, params|
        params[:association].options[:required]
      end
    end

    private

    def build_has_one(association)
      validate_association association

      {
        association.name =>
        {
          association: association
        }
      }
    end
  end
end
