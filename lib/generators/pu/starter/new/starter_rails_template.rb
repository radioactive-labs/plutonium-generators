def commit_changes(msg)
  git add: ".", commit: "-m '#{msg}'"
end

after_bundle do
  commit_changes "initial commit"

  generate "pu:setup:rails"
  commit_changes "setup rails"

  generate "pu:core:install"
  commit_changes "setup plutonium core"

  generate "pu:rodauth:install"
  commit_changes "install rodauth"

  generate "pu:rodauth:account admin"
  commit_changes "setup admin account"
end
