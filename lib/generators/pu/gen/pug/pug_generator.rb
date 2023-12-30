# frozen_string_literal: true

module Pu
  module Gen
    class PugGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Create a new pug'

      argument :name
      class_option :desc, type: :string, default: false, desc: 'Description of your pug'

      def start
        template 'pug.rb.tt', "lib/generators/pu/#{pug_name.underscore}.rb"
        create_file "lib/generators/pu/#{pug_name.underscore}/templates/.keep"
      end

      def rubocop
        run 'bundle exec rubocop -a'
      end

      protected

      def pug_name
        name.split(':').map(&:classify).join('::')
      end
    end
  end
end
