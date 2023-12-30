# frozen_string_literal: true

require File.expand_path('../../../../plutonium_generators', __dir__)
Dir[File.join(__dir__, 'concerns/*')].each do |file|
  require file
end

return unless PlutoniumGenerators.rails?

module Pu
  module Specs
    class ModelGenerator < Rails::Generators::Base
      include PlutoniumGenerators::Generator
      include ::Concerns::AttributesBuilder
      include ::Concerns::BelongsToBuilder
      include ::Concerns::HasManyBuilder
      include ::Concerns::HasOneBuilder
      include ::Concerns::FactoryBuilder
      include ::Concerns::ValidationsBuilder
      include ::Concerns::ScopeReader

      attr_reader :model_class, :model_class_name, :model_class_underscored, :table_name

      source_root File.expand_path('templates', __dir__)

      desc "Generates specs for a the model. Includes a spec file and a factory.\n\n" \
            "- Model must be a descendant of ActiveRecord::Base.\n" \
            "- Requires that all pending migrations be executed.\n" \
            "- Ensure that the databse is up and the app can connect to it.\n\n" \
            'Since you should not be testing library code, ' \
            "specs are skipped for models that do not inherit ApplicationRecord since \n" \
            "it is assumed that the model does not belong to your application.\n"\
            "To force the generation of a spec for such a model, pass the `--force-external-spec` flag.\n\n"

      argument :name
      class_option :factory, type: :boolean, default: true
      class_option :spec, type: :boolean, default: true
      class_option :force_external_spec, type: :boolean, default: false,
                                         desc: 'Force the generation of a spec for models in libraries/gems.'

      def start
        setup
        generate_specs
        generate_factories
        wrap_up
      rescue StandardError => e
        exception 'Model generation failed:', e
      end

      private

      def wrap_up
        unless polymorphic_belongs_to.empty?
          debug(
            "Failed to generate factories for the following polymorphic associations\n" \
            "#{polymorphic_belongs_to.map { |n| "#{model_class_name}.#{n}" }.join("\n")}"
          )
        end

        if lint?
          info 'Running factory_bot:lint'
          `rails factory_bot:lint factory=#{model_class_underscored}`
          info 'Completed factory_bot:lint'
        else
          info(
            "Run `rails factory_bot:lint factory=#{model_class_underscored}` to validate your generated factory.\n" \
            'Visit https://thoughtbot.github.io/factory_bot/linting-factories/summary.html for more information'
          )
        end
        success "Generation completed for model:#{model_class_name}"
      end

      def setup
        @model_class_name = name.classify
        @model_class = model_class_name.constantize
        @model_class_underscored = safely_underscore model_class_name
        @table_name = model_class_underscored.pluralize
        unless model_class < ActiveRecord::Base
          error "Model needs to be a descendant of ActiveRecord::Base: #{model_class_name}"
        end
      rescue NameError
        error "#{model_class_name} does not exist"
      end

      def generate_specs
        return unless options[:spec]
        return unless options[:external_spec] || model_class < ApplicationRecord

        [
          {
            src: 'model_spec.rb.tt',
            dest: "spec/models/#{model_class_underscored}_spec.rb",
            skip: true
          },
          {
            src: 'model_spec.auto.rb.tt',
            dest: "spec/models/#{model_class_underscored}_spec.auto.rb",
            force: true
          }
        ].each do |template|
          template template[:src], template[:dest], skip: template[:skip], force: template[:force]
        end
      end

      def generate_factories
        return unless options[:factory]

        [
          {
            src: 'model_factory.rb.tt',
            dest: "spec/factories/#{model_class_underscored}.rb",
            skip: true
          },
          {
            src: 'model_factory.auto.rb.tt',
            dest: "spec/factories/#{model_class_underscored}.auto.rb",
            force: true
          }
        ].each do |template|
          template(template[:src], template[:dest], skip: template[:skip], force: template[:force])
        end
      end

      def validate_association(association)
        association.check_validity!
      rescue StandardError => e
        exception "Ensure your association #{model_class}.#{association.name} is set up correctly:", e
      end

      def safely_underscore(value)
        value.to_s.underscore.tr('/', '_')
      end
    end
  end
end
