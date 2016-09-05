module Danger
  #
  # This is a danger plugin to detect any TODO/FIXME entries left in the code.
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

      @todos = DiffTodoFinder.new.find_diffs_containing_todos(diffs_of_interest)

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

      @todos.each do |todo|
        text = ": #{todo.text}" if todo.text
        markdown("- #{todo.file}#{text}")
      end
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
  end
end
