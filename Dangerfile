# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

todoist.message = "There are still some things to do in this PR."
todoist.warn_for_todos
todoist.print_todos_table
