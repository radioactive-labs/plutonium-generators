# frozen_string_literal: true

module Concerns
  module ScopeReader
    def read_scope(association_type, scope, association_name)
      src = File.read model_source_location
      regex = scope_reader_regex association_type, scope, association_name
      return unless regex =~ src

      match = ::Regexp.last_match(1)
      # https://github.com/thoughtbot/shoulda-matchers/issues/810
      match.strip unless match.include? ".not"
    end

    private

    def model_source_location
      @model_source_location ||= begin
        name_parts = model_class_name.split("::")
        module_name = name_parts.first
        class_name = name_parts.last

        module_name.constantize.const_source_location(class_name)[0]
      end
    end

    def scope_reader_regex(association_type, scope, association_name)
      Regexp.new ".*#{association_type} :#{association_name}.*->.*#{scope}[\\s{\\(]*([\\w\\d\\s\\.:,'\"]*).*}"
    end
  end
end
