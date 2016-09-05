module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    TODO_REGEXP = /
      ^\+                 # we only look at additions, marked by + in unified diff
      \s*                 # followed by optional space
      [^a-z0-9]*          # anything looking like a comment indicator
      \s+                 # followed by at least one space
      (TODO|FIXME)        # our todo indicator
      [\s:]?              # followed by a space or colon
      (?<text>.*)$        # matching the actual todo text until the end of the line
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

    # TODO: I want to see this
    class Todo < Struct.new(:file, :text)
    end

    # this however, is not supposed to be a todo
  end
end
