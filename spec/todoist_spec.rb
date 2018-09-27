require File.expand_path("../spec_helper", __FILE__)

# rubocop:disable Metrics/ModuleLength
module Danger
  # rubocop:disable Metrics/BlockLength
  describe Danger::DangerTodoist do
    it "should be a plugin" do
      expect(Danger::DangerTodoist.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @todoist = @dangerfile.todoist
      end

      context "changed files containing newly introduced todos" do
        before do
          patch = <<PATCH
+ # TODO: some todo
+ def foo
+ end
+ # TODO: more todo in same file
+ def foo; puts 1; end; # TODO: An inline todo
PATCH

          modified = Git::Diff::DiffFile.new(
            "base",
            path:  "some/file.rb",
            patch: patch
          )
          added = Git::Diff::DiffFile.new(
            "base",
            path:  "another/stuff.rb",
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
              "- another/stuff.rb",
              "  - Line 0: another todo",
              "- some/file.rb",
              "  - Line 0: some todo",
              "  - Line 3: more todo in same file",
              "  - Line : An inline todo"
            ]
          )
        end

        it "exposes todos to the dangerfile" do
          expect(@todoist.todos.length).to eq(4)
          expect(@todoist.todos.first.text).to eq("another todo")
          expect(@todoist.todos.last.file).to eq("some/file.rb")
        end
      end

      context "changed files not containing a todo" do
        before do
          modified = Git::Diff::DiffFile.new(
            "base",
            path:  "some/file.rb",
            patch: "+ some added line"
          )
          allow(@dangerfile.git).to receive(:diff_for_file)
            .with("some/file.rb").and_return(modified)

          allow(@dangerfile.git).to receive(:modified_files)
            .and_return(["some/file.rb"])
          allow(@dangerfile.git).to receive(:added_files).and_return([])
        end

        it "reports nothing" do
          @todoist.warn_for_todos
          @todoist.print_todos_table

          expect(warnings).to be_empty
          expect(markdowns).to be_empty
        end
      end

      it "does nothing when no files are in changeset" do
        allow(@dangerfile.git).to receive(:modified_files).and_return([])
        allow(@dangerfile.git).to receive(:added_files).and_return([])

        @todoist.warn_for_todos
        @todoist.fail_for_todos
        @todoist.print_todos_table

        expect(warnings).to be_empty
        expect(failures).to be_empty
        expect(markdowns).to be_empty
      end

      it "does not raise when git raises, but warns" do
        invalid = [nil, 0, false]
        allow(@dangerfile.git).to receive(:modified_files).and_return(invalid)
        allow(@dangerfile.git).to receive(:added_files).and_return(invalid)

        expect { @todoist.warn_for_todos }.to_not raise_error
        expect(markdowns).to include(
          "* danger-todoist was unable to determine diff for \"nil\"."
        )
        expect(markdowns).to include(
          "* danger-todoist was unable to determine diff for \"0\"."
        )
        expect(markdowns).to include(
          "* danger-todoist was unable to determine diff for \"false\"."
        )
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
# rubocop:enable Metrics/ModuleLength
