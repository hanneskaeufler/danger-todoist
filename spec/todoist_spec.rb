# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

# rubocop:disable Metrics/ModuleLength
module Danger
  describe Danger::DangerTodoist do
    it "is a plugin" do
      expect(described_class.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @todoist = @dangerfile.todoist
      end

      context "with changed files containing newly introduced todos" do
        before do
          patch = <<PATCH
+ # TODO: some todo
+ def foo
+ end
+ # TODO: more todo in same file
PATCH

          modified = Git::Diff::DiffFile.new(
            "base",
            path: "some/file.rb",
            patch: patch
          )
          added = Git::Diff::DiffFile.new(
            "base",
            path: "another/stuff.rb",
            patch: "+ # fixme: another todo"
          )

          allow(@dangerfile.git).to receive(:diff_for_file)
            .with("some/file.rb").and_return(modified)

          allow(@dangerfile.git).to receive(:diff_for_file)
            .with("another/stuff.rb").and_return(added)

          allow(@dangerfile.git).to receive(:modified_files)
            .and_return(["some/file.rb"])
          allow(@dangerfile.git).to receive(:added_files)
            .and_return(["another/stuff.rb"])
        end

        it "warns when files in the changeset" do
          @todoist.warn_for_todos

          expect(warnings).to eq([DangerTodoist::DEFAULT_MESSAGE])
        end

        it "fails when files in the changeset" do
          @todoist.fail_for_todos

          expect(failures).to eq([DangerTodoist::DEFAULT_MESSAGE])
        end

        it "allows the message to be changed" do
          @todoist.message = "changed message"
          @todoist.warn_for_todos

          expect(warnings).to eq(["changed message"])
        end

        it "allows the keywords to be changed" do
          @todoist.keywords = ["find-nothing"]
          @todoist.warn_for_todos

          expect(warnings).to be_empty
        end

        it "can print a report, even without warning first" do
          @todoist.print_todos_table

          expect(markdowns).to eq(
            [
              "#### Todos left in files",
              "- some/file.rb",
              "  - Line 0: some todo",
              "  - Line 3: more todo in same file",
              "- another/stuff.rb",
              "  - Line 0: another todo"
            ]
          )
        end

        it "exposes todos to the dangerfile" do
          expect(@todoist.todos).to match_array([
                                                  Todo.new("some/file.rb", "some todo", 0),
                                                  Todo.new("some/file.rb", "more todo in same file", 3),
                                                  Todo.new("another/stuff.rb", "another todo", 0)
                                                ])
        end
      end

      context "with changed files not containing a todo" do
        before do
          modified = Git::Diff::DiffFile.new(
            "base",
            path: "some/file.rb",
            patch: "+ some added line"
          )
          allow(@dangerfile.git).to receive(:diff_for_file)
            .with("some/file.rb").and_return(modified)

          allow(@dangerfile.git).to receive(:modified_files)
            .and_return(["some/file.rb"])
          allow(@dangerfile.git).to receive(:added_files).and_return([])
        end

        it "doesnt't report any warnings" do
          @todoist.warn_for_todos

          expect(warnings).to be_empty
        end

        it "doesn't report any markdown content" do
          @todoist.print_todos_table

          expect(markdowns).to be_empty
        end
      end

      it "does nothing when no files are in changeset" do
        allow(@dangerfile.git).to receive(:modified_files).and_return([])
        allow(@dangerfile.git).to receive(:added_files).and_return([])

        @todoist.warn_for_todos
        @todoist.fail_for_todos
        @todoist.print_todos_table

        expect(warnings + failures + markdowns).to be_empty
      end

      it "does not raise when git raises" do
        invalid = [nil, 0, false]
        allow(@dangerfile.git).to receive(:modified_files).and_return(invalid)
        allow(@dangerfile.git).to receive(:added_files).and_return(invalid)

        expect { @todoist.warn_for_todos }.not_to raise_error
      end

      it "warns when git raises" do
        invalid = [nil, 0, false]
        allow(@dangerfile.git).to receive(:modified_files).and_return(invalid)
        allow(@dangerfile.git).to receive(:added_files).and_return(invalid)

        @todoist.warn_for_todos

        expect(markdowns).to include(
          "* danger-todoist was unable to determine diff for \"nil\".",
          "* danger-todoist was unable to determine diff for \"0\".",
          "* danger-todoist was unable to determine diff for \"false\"."
        )
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
