# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  # rubocop:disable Metrics/BlockLength
  describe Danger::MatchesInDiff do
    describe "#todo_matches?" do
      it "is false for no matches" do
        expect(described_class.new("", []).todo_matches?).to be false
      end

      it "is true for some matches" do
        expect(described_class.new("", [["hey"]]).todo_matches?).to be true
      end
    end

    describe "#all_todos" do
      it "returns the correct line number for the first todo" do
        diff = sample_diff_fixture("sample_patch.diff")
        subject = described_class.new(
          diff,
          [[
            "+      #",
            "TODO",
            "What if there are multiple matching lines?",
            "What if there are multiple matching lines?"
          ]]
        )
        expect(subject.all_todos.first.line_number).to eq 50
      end

      it "returns the correct line number for the second todo" do
        diff = sample_diff_fixture("sample_patch.diff")
        subject = described_class.new(
          diff,
          [[
            "+      #",
            "TODO",
            "thats not gonna fly",
            "thats not gonna fly"
          ]]
        )
        expect(subject.all_todos.first.line_number).to eq 54
      end

      it "returns the correct line number for a multiline todo" do
        diff = sample_diff_fixture("multiline_todo_patch.diff")
        subject = described_class.new(
          diff,
          [[
            "+      #",
            "TODO",
            " I'd rather not have this here ...\n+  # because it's probably " \
            "just a bit of code that we can reimplement\n+  # or steal",
            " I'd rather not have this here ...", "\n+  # or steal"
          ]]
        )
        expect(subject.all_todos.first.line_number).to eq 22
      end

      it "raises when the todo string was not found in the patch" do
        diff = sample_diff_fixture("sample_patch.diff")
        subject = described_class.new(
          diff,
          [[
            "+      #",
            "TODO",
            "",
            "definately not contained in the patch"
          ]]
        )
        expect { subject.all_todos }.to raise_error(TextNotFoundInPatchError)
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
