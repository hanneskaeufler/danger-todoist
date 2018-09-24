module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    def initialize(keywords)
      @regexp = todo_regexp(keywords)
    end

    def call(diffs)
      possible_todos(diffs)
        .map do |combination|
          puts combination.diff.inspect
          combination.matches.map do |match|
            Danger::Todo.new(combination.diff.path, clean_todo_text(match), 5)
          end
        end
        .flatten
    end

    private

    def possible_todos(diffs)
      diffs
        .map { |diff| MatchesInDiff.new(diff, diff.patch.scan(@regexp)) }
        .reject { |combination| combination.matches.empty? }
    end

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
    def todo_regexp(keywords)
      /
      (?<comment_indicator>^\+\s*[^a-z0-9\+\s]+)
      (\n\+)?\s+
      (?<todo_indicator>#{keywords.join("|")})[\s:]{1}
      (?<entire_text>(?<text>[^\n]*)
      (?<rest>\n\k<comment_indicator>\s*[\w .]*)*)
      /ixm
    end
  end

  class MatchesInDiff < Struct.new(:diff, :matches)
  end
end
