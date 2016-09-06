require File.expand_path("../spec_helper", __FILE__)

module Danger
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
          modified = Git::Diff::DiffFile.new(
            "base",
            path:  "some/file.rb",
            patch: "+ # TODO: some todo"
          )
          added = Git::Diff::DiffFile.new(
            "base",
            path:  "another/stuff.rb",
            patch: "+ # fixme: another todo"
          )

          allow(@dangerfile.git).to receive(:diff_for_file)
            .with("some/file.rb")
            .and_return(modified)

          allow(@dangerfile.git).to receive(:diff_for_file)
            .with("another/stuff.rb")
            .and_return(added)

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

        it "can print a report, even without warning first" do
          @todoist.print_todos_table

          expect(markdowns).to eq(
            [
              "#### Todos left in files",
              "- some/file.rb: some todo",
              "- another/stuff.rb: another todo"
            ]
          )
        end

        it "exposes todos to the dangerfile" do
          expect(@todoist.todos.length).to eq(2)
          expect(@todoist.todos.first.text).to eq("some todo")
          expect(@todoist.todos.last.file).to eq("another/stuff.rb")
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
            .with("some/file.rb")
            .and_return(modified)

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
        @todoist.print_todos_table

        expect(warnings).to be_empty
        expect(markdowns).to be_empty
      end
    end

    def failures
      @dangerfile.status_report[:errors]
    end

    def warnings
      @dangerfile.status_report[:warnings]
    end

    def markdowns
      @dangerfile.status_report[:markdowns].map(&:message)
    end
  end
end
