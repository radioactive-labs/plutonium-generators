# frozen_string_literal: true

module Concerns
  module HasManyBuilder
    # rubocop:disable Naming/PredicateName
    def has_many
      @has_many ||= model_class.reflect_on_all_associations(:has_many).each_with_object({}.with_indifferent_access) do |assoc, hash|
        hash.merge! build_has_many(assoc)
      end
    end
    # rubocop:enable Naming/PredicateName

    private

    def build_has_many(association)
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
