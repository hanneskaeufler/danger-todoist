module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    def initialize(keywords)
      @keywords = keywords
    end

    def call(diffs)
      todos = []
      regexp = todo_regexp
      diffs.each do |diff|
        matches = diff.patch.scan(regexp)
        next if matches.empty?

        matches.each do |match|
          todos << Danger::Todo.new(diff.path, clean_todo_text(match))
        end
      end
      todos
    end

    private

    def clean_todo_text(match)
      comment_indicator, _, entire_todo = match
      entire_todo.gsub(comment_indicator, "")
                 .delete("\n")
                 .strip
    end

    # this is quite a mess now ... I knew it would haunt me.
    # to aid debugging, this online regexr can be
    # used: http://rubular.com/r/DPkoE2ztpn
    # the regexp uses backreferences to match the comment indicator multiple
    # times if possible
    def todo_regexp
      /
      (?<comment_indicator>^\+\s*[^a-z0-9\+\s]+)
      (\n\+)?\s+
      (?<todo_indicator>#{@keywords.join("|")})[\s:]{1}
      (?<entire_text>(?<text>[^\n]*)
      (?<rest>\n\k<comment_indicator>\s*[\w .]*)*)
      /ixm
    end
  end
end
