module Danger
  # Identify inline todos in a set of diffs
  class DiffInlineTodoFinder
    def initialize(keywords)
      @keywords = keywords
    end

    def call(diffs)
      diffs.map do |diff|
        diff.patch.scan(/\+ .+(#{keywords})[\s:]{1}(.+)$/).map do |match|
          Todo.new(diff.path, match[1].strip)
        end
      end.flatten
    end

    private

    def keywords
      @keywords.join("|")
    end
  end
end
