is_wip = github.pr_title.include? "[WIP]"
is_trivial = github.pr_title.include? "[trivial]"
is_big_pr = git.lines_of_code > 500
has_insufficient_description = github.pr_body.length < 5
has_updated_changelog = git.modified_files.include?("CHANGELOG.md")

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if is_wip

# Warn when there is a big PR
warn("Wow that's a lot of changes. Can we split this up?") if is_big_pr

# Reminder to add changelog entry
if !has_updated_changelog && !is_trivial
  fail("Please include a CHANGELOG entry.", sticky: false)
end

# Identify leftover todos
todoist.message = "There are still some things to do in this PR."
todoist.warn_for_todos
todoist.print_todos_table

# Mainly to encourage writing up some reasoning about the PR, rather than
# just leaving a title
if has_insufficient_description
  fail "Please provide a summary in the Pull Request description"
end
