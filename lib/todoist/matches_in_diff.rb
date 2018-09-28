module Danger
  # Identify todos in a single diff
  module TodoBuilder
    def todo_matches?
      !matches.empty?
    end

    def all_todos
      matches.map { |match| build_todo(diff.path, match) }
    end

    private

    def build_todo(path, match)
      Danger::Todo.new(path, cleaned_todo_text(match), line_number(match))
    end
  end

  # ???
  class MatchesInDiff < Struct.new(:diff, :matches)
    include TodoBuilder

    def line_number(match)
      _, _, _, text = match
      Patch.new(diff.patch).changed_lines.each do |line|
        return line.number if line.content.include? text
      end
      raise TextNotFoundInPatchError, "The matched todo text \"#{text}\""\
        "wasn't found in the patch:\n#{diff.patch}"
    end

    def cleaned_todo_text(match)
      comment_indicator, _, entire_todo = match
      entire_todo
        .gsub(comment_indicator, "")
        .delete("\n")
        .strip
    end
  end

  # ???
  class InlineMatchesInDiff < Struct.new(:diff, :matches)
    include TodoBuilder

    def cleaned_todo_text(match)
      match[1].strip
    end

    def line_number(match)
      text = match[1]
      puts text

      Patch.new(diff.patch).changed_lines.each do |line|
        puts line.inspect
        return line.number if line.content.include? text
      end
      raise TextNotFoundInPatchError, "The matched todo text \"#{text}\""\
        "wasn't found in the patch:\n#{diff.patch}"
    end
  end

  # Parsed patch
  class Patch
    RANGE_INFORMATION_LINE = /^@@ .+\+(?<line_number>\d+),/
    MODIFIED_LINE = /^\+(?!\+|\+)/
    REMOVED_LINE = /^[-]/
    NOT_REMOVED_LINE = /^[^-]/

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

  class TextNotFoundInPatchError < RuntimeError
  end
end
