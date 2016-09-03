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

      context "Files containing a todo" do
        before do
          modified = ["a"]
          allow(@dangerfile.git).to receive(:modified_files).and_return(modified)
          allow(@dangerfile.git).to receive(:added_files).and_return([])
        end

        it "Warns when files in the changeset" do
          @todoist.warn_on_mondays

          expect(@dangerfile.status_report[:warnings]).to eq(["Foo the bar"])
        end

        it "allows the message to be changed" do
          @todoist.message = "changed message"
          @todoist.warn_on_mondays

          expect(@dangerfile.status_report[:warnings]).to eq(["changed message"])
        end
      end

      it "Does nothing when no files are in changeset" do
        allow(@dangerfile.git).to receive(:modified_files).and_return([])
        allow(@dangerfile.git).to receive(:added_files).and_return([])

        @todoist.warn_on_mondays

        expect(@dangerfile.status_report[:warnings]).to be_empty
      end
    end
  end
end

