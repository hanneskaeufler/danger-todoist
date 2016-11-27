require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DiffTodoFinder do
    let(:subject) { Danger::DiffTodoFinder.new }

    describe "#find_diffs_containing_todos" do
      %w(TODO TODO: todo todo: FIXME fixme FIXME: fixme).each do |marker|
        it "identifies a new '#{marker}' as a todo" do
          diff = sample_diff("+ # #{marker} some todo")

          todos = subject.find_diffs_containing_todos([diff])

          expect(todos).to_not be_empty
        end
      end

      it "identifies todos with changed finder string" do
        diff = sample_diff("+ # BUG some todo")

        subject = described_class.new(["BUG"])
        todos = subject.find_diffs_containing_todos([diff])

        expect(todos).to_not be_empty
      end

      # those comment indicators are ripped off https://github.com/pgilad/leasot
      %w(# {{ -- // /* <!-- <%# % / -# {{! {{!-- {# <%--).each do |comment|
        it "identifies todos in languages with '#{comment}' as comments" do
          diff = sample_diff("+ #{comment} TODO: some todo")

          todos = subject.find_diffs_containing_todos([diff])

          expect(todos).to_not be_empty
        end
      end

      it "does not identify removed todos as a todo" do
        diff = sample_diff("- TODO: some todo")

        todos = subject.find_diffs_containing_todos([diff])

        expect(todos).to be_empty
      end

      [
        "+ class TodosController",
        "+ function foo(todo) {",
        "+ def todo()",
        "+ def todo foo",
        "+ * this looks like a todo but isnt",
        "+ TODO_REGEXP = /",
        "+          todos = subject.find_diffs_containing_todos(diffs)",
        "++ # FIXME: with you the force is",
        "+ TODO: foo",
        "+ TODO",
        "+   TODO: something"
      ].each do |patch|
        it "does not identify occurences in '#{patch}'" do
          diff = sample_diff("some/file.rb")

          todos = subject.find_diffs_containing_todos([diff])

          expect(todos).to be_empty
        end
      end

      it "identifies the todo text as well" do
        diff = sample_diff("+ # TODO: practice you must")

        todos = subject.find_diffs_containing_todos([diff])

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

        diff = sample_diff(patch)

        todos = subject.find_diffs_containing_todos([diff])

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

        diff = sample_diff(patch)

        todos = subject.find_diffs_containing_todos([diff])

        expect(todos.map(&:text)).to eql(%w(something another))
      end
    end
  end
end
