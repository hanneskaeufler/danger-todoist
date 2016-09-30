# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Reminder to add changelog entry
unless git.modified_files.include?("CHANGELOG.md")
  fail("Please include a CHANGELOG entry.", sticky: false)
end

# Identify leftover todos
todoist.message = "There are still some things to do in this PR."
todoist.warn_for_todos
todoist.print_todos_table

# Mainly to encourage writing up some reasoning about the PR, rather than
# just leaving a title
if github.pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end
