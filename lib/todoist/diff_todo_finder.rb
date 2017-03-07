module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    def initialize(keywords)
      @keywords = keywords
    end

    # TODO: this must be cleaned up
    # by quite a bit
    def find_diffs_containing_todos(diffs)
      todos = []
      regexp = todo_regexp
      diffs.each do |diff|
        matches = diff.patch.scan(regexp)
        next if matches.empty?
        # require "pry"
        # binding.pry

        matches.each do |match|
          comment_indicator = match[0]
          entire_todo = match[2]
          rest = match[4]
          final_todo = entire_todo
            .gsub(rest || "", "")
            .gsub(comment_indicator, "")
            .gsub(/\n/, "")
            .strip
          todos << Danger::Todo.new(diff.path, final_todo)
        end
      end
      todos
    end

    private

    def todo_regexp
      /(?<comment_indicator>^\+\s*[^a-z0-9\+\s]+)(\n\+)?\s+(?<todo_indicator>#{@keywords.join("|")})[\s:]{1}(?<entire_text>(?<text>[^\n]*)(?<rest>\n\k<comment_indicator>\s*[^\n]*)*)/ixm
      # /
      # (?<comment_indicator>^\+        # we only look at additions, marked by + in diffs
      # \s*                 # followed by optional space
      # [^a-z0-9\+\s]+)    # anything looking like a comment indicator
      # (\n\+)?             # allow multiline comment markers
      # \s+                 # followed by at least one space
      # (?<todo_indicator>#{@keywords.join("|")})       # our todo indicator
      # [\s:]{1}            # followed by a space or colon
      # (?<text>.*)(\n\<comment_indicator>\s+.*|$)*        # matching any text until the end of the line
    # /ix
    end
  end
end
