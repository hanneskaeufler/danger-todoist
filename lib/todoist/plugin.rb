module Danger
  #
  # @example Ensure there are no TODOS left in the modified code
  #
  #          todoist.warn_for_todos
  #
  # @example Set custom warning message
  #
  #          todois.message = "Please fix all TODOS"
  #          todoist.warn_for_todos
  #
  # @example List every todo item
  #
  #          todoist.warn_for_todos
  #          todoist.print_todos_table
  #
  # @see  hanneskaeufler/danger-todoist
  # @tags todos, fixme
  #
  class DangerTodoist < Plugin
    DEFAULT_MESSAGE = "There remain todo items in the modified code.".freeze
    TODO_REGEXP = /TODO|FIXME/i

    #
    # Message to be shown
    #
    # @attr_writer [String] message Custom message shown when todos were found
    # @return [void]
    #
    attr_writer :message

    #
    # Adds a warning if there are todos found in the modified code
    #
    # @return [void]
    #
    def warn_for_todos
      @todos = []
      return if files_of_interest.empty?

      diffs_containing_todo_markers
        .each { |diff| @todos << Todo.new(diff.path) }

      warn(message) unless @todos.empty?
    end

    #
    # Adds a list of offending files to the danger comment
    #
    # @return [void]
    #
    def print_todos_table
      return if @todos.nil?
      return if @todos.empty?

      markdown("#### Todos left in files")

      @todos
        .map { |todo| "- #{todo.file}" }
        .map { |message| markdown(message) }
    end

    private

    def message
      return @message unless @message.nil?
      DEFAULT_MESSAGE
    end

    def files_of_interest
      git.modified_files + git.added_files
    end

    def diffs_of_interest
      files_of_interest
        .map { |file| git.diff_for_file(file) }
    end

    def diffs_containing_todo_markers
      diffs_of_interest
        .select { |diff| contains_new_todo(diff) }
    end

    def contains_new_todo(diff)
      !(diff.patch =~ TODO_REGEXP).nil?
    end

    class Todo < Struct.new(:file)
    end
  end
end
