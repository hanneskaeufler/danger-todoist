# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

# rubocop:disable Metrics/ModuleLength
module Danger
  # rubocop:disable Metrics/BlockLength
  describe Danger::DiffTodoFinder do
    let(:subject) do
      Danger::DiffTodoFinder.new(%w(TODO FIXME))
    end

    describe "#call" do
      %w(TODO TODO: todo todo: FIXME fixme FIXME: fixme).each do |marker|
        it "identifies a new '#{marker}' as a todo" do
          diff = sample_diff("+ # #{marker} some todo")

          todos = subject.call([diff])

          expect(todos).to_not be_empty
        end
      end

      it "identifies todos with changed finder string" do
        diff = sample_diff("+ # BUG some todo")

        subject = described_class.new(["BUG"])
        todos = subject.call([diff])

        expect(todos).to_not be_empty
        expect(todos.first.line_number).to be 0
      end

      it "doesnt crash but also doesnt find anything with empty keywords" do
        diff = sample_diff("+ # BUG some todo")

        subject = described_class.new([])
        todos = subject.call([diff])

        expect(todos).to be_empty
      end

      # those comment indicators are ripped off https://github.com/pgilad/leasot
      %w(# {{ -- // /* <!-- <%# % / -# {{! {{!-- {# <%--).each do |comment|
        it "identifies todos in languages with '#{comment}' as comments" do
          diff = sample_diff("+ #{comment} TODO: some todo")

          todos = subject.call([diff])

          expect(todos).to_not be_empty
        end
      end

      it "does not identify removed todos as a todo" do
        diff = sample_diff("- TODO: some todo")

        todos = subject.call([diff])

        expect(todos).to be_empty
      end

      [
        "+ class TodosController",
        "+ function foo(todo) {",
        "+ def todo()",
        "+ def todo foo",
        "+ * this looks like a todo but isnt",
        "+ TODO_REGEXP = /",
        "+          todos = subject.call(diffs)",
        "++ # FIXME: with you the force is",
        "+ TODO: foo",
        "+ TODO",
        "+   TODO: something"
      ].each do |patch|
        it "does not identify occurences in '#{patch}'" do
          diff = sample_diff("some/file.rb")

          todos = subject.call([diff])

          expect(todos).to be_empty
        end
      end

      it "identifies the todo text as well" do
        diff = sample_diff("+ # TODO: practice you must")

        todos = subject.call([diff])

        expect(todos.first.text).to eql("practice you must")
      end

      it "finds multiple todos in the same diff" do
        patch = <<PATCH
+ # TODO: practice you must
+ def practice
+   return false
+ end
+ # FIXME: with you the force is
PATCH

        todos = subject.call([sample_diff(patch)])

        expect(todos.map(&:text))
          .to eql(["practice you must", "with you the force is"])
      end

      it "finds todos in multiline comments" do
        patch = <<PATCH
+ /*
+  TODO: something
+ */
+ function bla() {};
+ /**
+  * TODO: another
+  */
PATCH

        todos = subject.call([sample_diff(patch)])

        expect(todos.map(&:text)).to eql(%w(something another))
      end

      it "can extract multiline todo text" do
        patch = <<PATCH
+ /**
+  * TODO: this should be parsed as
+  * a single item.
+  */
+ # TODO: this is a
+ # multiline comment as well
+ function bla() {};
+  # TODO: I'd rather not have this here ...
+  # because it's probably just a bit of code that we can reimplement
+  # or steal
PATCH

        todos = subject.call([sample_diff(patch)])

        expect(todos.map(&:text))
          .to eql(["this should be parsed as a single item.",
                   "this is a multiline comment as well",
                   "I'd rather not have this here ... because it's probably " \
                   "just a bit of code that we can reimplement or steal"])
      end

      it "ignores pre-existing todos found in the context lines of a patch" do
        diff = sample_diff_fixture("preexisting_todo.diff")
        todos = subject.call([diff])
        expect(todos).to be_empty
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
# rubocop:enable Metrics/ModuleLength
