require "simplecov"
if ENV["COVERAGE"]
  SimpleCov.start do
    add_filter "/spec/"
  end
end

require "pathname"
ROOT = Pathname.new(File.expand_path("..", __dir__))
$LOAD_PATH.unshift((ROOT + "lib").to_s)
$LOAD_PATH.unshift((ROOT + "spec").to_s)

require "bundler/setup"
require "pry"

require "rspec"
require "danger"

# Use coloured output, it"s the best.
RSpec.configure do |config|
  config.filter_gems_from_backtrace "bundler"
  config.color = true
  config.tty = true
end

require "danger_plugin"

# These functions are a subset of https://github.com/danger/danger/blob/master/spec/spec_helper.rb
# If you are expanding these files, see if it"s already been done ^.

# A silent version of the user interface,
# it comes with an extra function `.string` which will
# strip all ANSI colours from the string.

# rubocop:disable Lint/NestedMethodDefinition
def testing_ui
  @output = StringIO.new
  def @output.winsize
    [20, 9999]
  end

  cork = Cork::Board.new(out: @output)
  def cork.string
    out.string.gsub(/\e\[([;\d]+)?m/, "")
  end
  cork
end
# rubocop:enable Lint/NestedMethodDefinition

# Example environment (ENV) that would come from
# running a PR on TravisCI
def testing_env
  {
    "HAS_JOSH_K_SEAL_OF_APPROVAL" => "true",
    "TRAVIS_PULL_REQUEST" => "800",
    "TRAVIS_REPO_SLUG" => "artsy/eigen",
    "TRAVIS_COMMIT_RANGE" => "759adcbd0d8f...13c4dc8bb61d",
    "DANGER_GITHUB_API_TOKEN" => "123sbdq54erfsd3422gdfio"
  }
end

# A stubbed out Dangerfile for use in tests
def testing_dangerfile
  env = Danger::EnvironmentManager.new(testing_env, testing_ui)
  Danger::Dangerfile.new(env, testing_ui)
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

def sample_diff(patch)
  Git::Diff::DiffFile.new(
    "base",
    src: "src",
    dst: "dst",
    path: "some/file.rb",
    patch: patch
  )
end

def sample_diff_fixture(filename)
  sample_diff(File.read(File.expand_path("./fixtures/#{filename}", __dir__)))
end
