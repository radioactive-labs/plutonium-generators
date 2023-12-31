gem_group :development, :test do
  gem "plutonium_generators", path: "/Users/stefan/code/plutonium/plutonium_generators"
end

after_bundle do
  git add: "."
  git commit: %( -m 'initial commit' )

  generate "pu:setup:rails"
  git commit: %( -m 'setup plutonium starter' )
end
