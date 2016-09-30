module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    TODO_REGEXP = /
      ^\+                 # we only look at additions, marked by + in diffs
      \s*                 # followed by optional space
      [^a-z0-9\+\s]+      # anything looking like a comment indicator
      (\n\+)?             # allow multiline comment markers
      \s+                 # followed by at least one space
      (TODO|FIXME)        # our todo indicator
      [\s:]{1}            # followed by a space or colon
      (?<text>.*)$        # matching any text until the end of the line
    /ix

    def find_diffs_containing_todos(diffs)
      todos = []
      diffs.each do |diff|
        matches = diff.patch.scan(TODO_REGEXP)
        next if matches.empty?

        matches.each do |match|
          todos << Danger::Todo.new(diff.path, match.first.strip)
        end
      end
      todos
    end
  end
end
