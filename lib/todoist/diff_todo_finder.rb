module Danger
  # Identify todos in a set of diffs
  class DiffTodoFinder
    TODO_REGEXP = /\+.*(TODO|FIXME)[\s:]/i

    def find_diffs_containing_todos(diffs)
      diffs
        .select { |diff| contains_new_todo(diff) }
        .map { |diff| Todo.new(diff.path) }
    end

    private

    def contains_new_todo(diff)
      # TODO: This will match removed todos as well
      !(diff.patch =~ TODO_REGEXP).nil?
    end

    class Todo < Struct.new(:file)
    end
  end
end
