# frozen_string_literal: true

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
      (?<comment_indicator>^\+\s*[^a-z0-9+\s]+)
      (\n\+)?\s+
      (?<todo_indicator>#{keywords.join("|")})[\s:]{1}
      (?<entire_text>(?<text>[^\n]*)
      (?<rest>\n\k<comment_indicator>\s*[\w .']*)*)
      /ixm
    end
  end

  # Identify todos in a single diff
  class MatchesInDiff < Struct.new(:diff, :matches)
    def todo_matches?
      !matches.empty?
    end

    def all_todos
      matches.map { |match| build_todo(diff.path, match) }
    end

    private

    def line_number(match)
      _, _, _, first_text = match
      Patch.new(diff.patch).changed_lines.each do |line|
        return line.number if line.content.include? first_text
      end
      raise TextNotFoundInPatchError
    end

    def build_todo(path, match)
      Danger::Todo.new(path, cleaned_todo_text(match), line_number(match))
    end

    def cleaned_todo_text(match)
      comment_indicator, _, entire_todo = match
      entire_todo.gsub(comment_indicator, "")
                 .delete("\n")
                 .strip
    end

    # Parsed patch
    class Patch
      RANGE_INFORMATION_LINE = /^@@ .+\+(?<line_number>\d+),/.freeze
      MODIFIED_LINE = /^\+(?!\+|\+)/.freeze
      REMOVED_LINE = /^-/.freeze
      NOT_REMOVED_LINE = /^[^-]/.freeze

      def initialize(body)
        @body = body
      end

      # rubocop:disable Metrics/MethodLength
      def changed_lines
        line_number = 0

        lines_with_index
          .each_with_object([]) do |(content, patch_position), lines|
            case content
            when RANGE_INFORMATION_LINE
              line_number = Regexp.last_match[:line_number].to_i
            when MODIFIED_LINE
              lines << Line.new(content, line_number, patch_position)
              line_number += 1
            when NOT_REMOVED_LINE
              line_number += 1
            end
          end
      end
      # rubocop:enable Metrics/MethodLength

      def lines
        @body.lines
      end

      def lines_with_index
        lines.each_with_index
      end
    end

    # Parsed line
    class Line < Struct.new(:content, :number, :patch_position)
    end
  end

  class TextNotFoundInPatchError < RuntimeError
  end
end
