module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    TODO_REGEXP = /\+.*(TODO|FIXME)[\s:](?<text>.*)$/i

    def find_diffs_containing_todos(diffs)
      # TODO: This will match removed todos as well
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
