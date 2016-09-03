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
  #          my_plugin.warn_on_mondays
  #
  # @see  hanneskaeufler/danger-todoist
  # @tags monday, weekends, time, rattata
  #
  class DangerTodoist < Plugin
    DEFAULT_MESSAGE = "Foo the bar"

    attr_accessor :message

    def message
      return @message unless @message.nil?
      DEFAULT_MESSAGE
    end

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #
    def warn_on_mondays
      files = git.modified_files + git.added_files

      unless files.empty?
        warn(message)
      end
    end
  end
end
