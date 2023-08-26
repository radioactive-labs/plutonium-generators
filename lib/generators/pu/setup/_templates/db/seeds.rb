# frozen_string_literal: true

# This file loads all seeds required to contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Seeds go into the `./seeds` directory
# - Seeds are sorted and loaded in order.
# - Seeds named with the `.all.rb` suffix are loaded on all environments e.g. `seed_users.all.rb`
# - Seeds named with the `.#{Rails.env}.rb` suffix are loaded on that specific environments e.g. `seed_users.prod.rb`
#
# Best Practices
# 1. If possible, do not make seeds dependent on each other.
# 2. If seeds need to be dependent, ensure that the naming order is maintained.
#     You can use `rails g pu:seed create_users --env prod` to create seeds that maintain order.
# 3. Seeds will be loaded multiple times. Ensure that your seeds are idempotent.
#     E.g. by using find_or_create_by!/create_or_find_by!
#   a. If you are gonna seed it, add a unique index that is not the primary key.
# 4. When persisting records, use versions of the method that raise on failure e.g. create!, save!

ActiveRecord::Base.transaction do
  Dir[
      File.expand_path('seeds/*.all.rb', __dir__),
      File.expand_path("seeds/*.#{Rails.env}.rb", __dir__)
  ].sort.each do |file|
    puts "Seeding #{File.basename file}"
    require file
  end
end
