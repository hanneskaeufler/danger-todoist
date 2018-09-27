module Danger
  # Identify inline todos in a set of diffs
  class DiffInlineTodoFinder
    def initialize(keywords)
      @keywords = keywords.join("|")
    end

    def call(diffs)
      diffs.map do |diff|
        diff.patch.scan(todo_regexp).map do |match|
          Todo.new(diff.path, match[1].strip)
        end
      end.flatten
    end

    private

    def todo_regexp
      @regexp ||= /\+ .{3,}(#{@keywords})[\s:]{1}(.+)$/
    end
  end
end
