require File.expand_path("../spec_helper", __FILE__)

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
        patch = File.read(File.expand_path("./sample_patch.diff", __dir__))
        diff = sample_diff(patch)
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
        patch = File.read(File.expand_path("./sample_patch.diff", __dir__))
        diff = sample_diff(patch)
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
    end
  end
  # rubocop:enable Metrics/BlockLength
end
