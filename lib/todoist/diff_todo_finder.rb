module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    TODO_REGEXP = /
      ^\+                 # we only look at additions, marked by + in diffs
      \s*                 # followed by optional space
      [^a-z0-9]*          # anything looking like a comment indicator
      \s+                 # followed by at least one space
      (TODO|FIXME)        # our todo indicator
      [\s:]{1}            # followed by a space or colon
      (?<text>.*)$        # matching any text until the end of the line
    /ix

    def find_diffs_containing_todos(diffs)
      todos = []
      diffs.each do |diff|
        matches = diff.patch.match(TODO_REGEXP)
        next if matches.nil?

        text = matches[1] if matches[1]
        todos << Todo.new(diff.path, text.strip)
      end
      todos
    end

    class Todo < Struct.new(:file, :text)
    end
  end
end
