require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DiffInlineTodoFinder do
    let(:subject) { Danger::DiffInlineTodoFinder.new(%w(TODO FIXME)) }

    describe "#call" do
      it "finds todos inline after code" do
        patch = <<PATCH
+ function bla() {}; // TODO: fix this
PATCH

        diff = sample_diff(patch)

        todos = subject.call([diff])

        expect(todos.first.text).to eq("fix this")
      end
    end
  end
end
