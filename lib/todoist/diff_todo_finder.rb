module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    def initialize(keywords)
      @regexp = todo_regexp(keywords)
    end

    # rubocop:disable Metrics/MethodLength
    def call(diffs)
      diffs
        .map do |diff|
          # Should only look for matches *within* the changed lines of a patch
          # (lines that begin with "+"), not the entire patch.
          # The current regexp doesn't enforce this correctly in some cases.
          patch = MatchesInDiff::Patch.new(diff.patch)
          matches = patch.changed_lines
                         .map(&:content)
                         .join
                         .scan(@regexp)

          MatchesInDiff.new(diff, matches)
        end
        .select(&:todo_matches?)
        .map(&:all_todos)
        .flatten
    end
    # rubocop:enable Metrics/MethodLength

    private

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
      (?<rest>\n\k<comment_indicator>\s*[\w .']*)*)
      /ixm
    end
  end
end
