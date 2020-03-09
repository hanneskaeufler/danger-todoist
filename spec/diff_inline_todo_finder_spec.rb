require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DiffInlineTodoFinder do
    let(:subject) { Danger::DiffInlineTodoFinder.new(%w(TODO FIXME)) }

    describe "#call" do
      it "finds todos inline after code" do
        patch = "+ function bla() {}; // TODO: fix this"

        todos = subject.call([sample_diff(patch)])

        expect(todos.first.text).to eq("fix this")
      end

      it "doesn't find floating todos" do
        patch = <<-PATCH
        + # TODO: practice you must
        + def practice
        +   return false
        + end
        + # FIXME: with you the force is
        PATCH

        todos = subject.call([sample_diff(patch)])

        expect(todos).to be_empty
      end

      it "records line_numbers" do # TODO: Record line numbers
        todos = subject.call([sample_diff_fixture("inline_todo_patch.diff")])

        expect(todos.map(&:line_number)).to eq [32]
      end
    end
  end
end
