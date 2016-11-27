module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    def initialize(keywords = %w(TODO FIXME))
      @keywords = keywords
    end

    def find_diffs_containing_todos(diffs)
      todos = []
      regexp = todo_regexp
      diffs.each do |diff|
        matches = diff.patch.scan(regexp)
        next if matches.empty?

        matches.each do |match|
          todos << Danger::Todo.new(diff.path, match.first.strip)
        end
      end
      todos
    end

    private

    def todo_regexp
      /
      ^\+                 # we only look at additions, marked by + in diffs
      \s*                 # followed by optional space
      [^a-z0-9\+\s]+      # anything looking like a comment indicator
      (\n\+)?             # allow multiline comment markers
      \s+                 # followed by at least one space
      (#{@keywords.join("|")})       # our todo indicator
      [\s:]{1}            # followed by a space or colon
      (?<text>.*)$        # matching any text until the end of the line
    /ix
    end
  end
end
