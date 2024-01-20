def commit_changes(msg)
  git add: "."
  git commit: %( -m msg )
end

gem_group :development, :test do
  gem "plutonium_generators", path: "/Users/stefan/code/plutonium/plutonium_generators"
end

after_bundle do
  commit_changes "initial commit"

  generate "pu:setup:rails"
  commit_changes "setup rails"

  generate "pu:base:install"
  commit_changes "setup plutonium base"

  generate "pu:rodauth:install"
  commit_changes "install rodauth"

  generate "pu:rodauth:account admin"
  commit_changes "setup admin account"
end
