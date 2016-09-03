module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          todoist.warn_for_todos
  #
  # @see  hanneskaeufler/danger-todoist
  # @tags todos, fixme
  #
  class DangerTodoist < Plugin
    DEFAULT_MESSAGE = "There remain todo items in the modified code.".freeze
    TODO_REGEXP = /TODO/

    attr_accessor :message, :todos

    def message
      return @message unless @message.nil?
      DEFAULT_MESSAGE
    end

    def warn_for_todos
      self.todos = []
      return if files_of_interest.empty?

      diffs_of_interest
        .select { |diff| contains_new_todo(diff) }
        .each { |diff| todos << Todo.new(diff.path) }

      warn(message) unless todos.empty?
    end

    def print_todos_table
      return if todos.nil?
      return if todos.empty?

      markdown("#### Todos left in files")

      todos
        .map { |todo| "- #{todo.file}" }
        .map { |message| markdown(message) }
    end

    private

    def files_of_interest
      git.modified_files + git.added_files
    end

    def diffs_of_interest
      files_of_interest
        .map { |file| git.diff_for_file(file) }
    end

    def contains_new_todo(diff)
      !(diff.patch =~ TODO_REGEXP).nil?
    end

    class Todo < Struct.new(:file)
    end
  end
end
