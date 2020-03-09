module Danger
  # Identify inline todos in a set of diffs
  class DiffInlineTodoFinder
    def initialize(keywords)
      @regexp = todo_regexp(keywords.join("|"))
    end

    def call(diffs)
      diffs
        .map do |diff|
          InlineMatchesInDiff.new(diff, diff.patch.scan(@regexp))
        end
        .select(&:todo_matches?)
        .map(&:all_todos)
        .flatten
    end

    private

    def todo_regexp(keywords)
      /\+ .{3,}(#{keywords})[\s:]{1}(.+)$/
    end
  end
end
