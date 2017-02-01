[![Build Status](https://travis-ci.org/hanneskaeufler/danger-todoist.svg?branch=master)](https://travis-ci.org/hanneskaeufler/danger-todoist) [![Gem Version](https://badge.fury.io/rb/danger-todoist.svg)](https://badge.fury.io/rb/danger-todoist) [![Code Climate](https://codeclimate.com/github/hanneskaeufler/danger-todoist/badges/gpa.svg)](https://codeclimate.com/github/hanneskaeufler/danger-todoist) [![Test Coverage](https://codeclimate.com/github/hanneskaeufler/danger-todoist/badges/coverage.svg)](https://codeclimate.com/github/hanneskaeufler/danger-todoist/coverage)

# danger-todoist

danger-todoist is a [https://danger.systems](https://danger.systems) plugin to automatically notify you of
todos left in the code of a pull/merge request.

## Installation

Add `gem 'danger-todoist'` to your `Gemfile` and start using todoist in your `Dangerfile`.

## Usage

    Methods and attributes from this plugin are available in
    your `Dangerfile` under the `todoist` namespace.

<blockquote>Ensure, by warning, there are no TODOS left in the modified code
  <pre>
todoist.warn_for_todos</pre>
</blockquote>

<blockquote>Ensure, by failing the build, no TODOS left in the modified code
  <pre>
todoist.fail_for_todos</pre>
</blockquote>

<blockquote>Set custom warning message for warning
  <pre>
todoist.message = "Please fix all TODOS"
todoist.warn_for_todos</pre>
</blockquote>

<blockquote>List every todo item
  <pre>
todoist.warn_for_todos
todoist.print_todos_table</pre>
</blockquote>

<blockquote>Do anything with the todos. Todos have `text` and `file` properties
  <pre>
todoist.todos.each { |todo| puts todo.text }</pre>
</blockquote>

#### Attributes

`message` - Message to be shown

#### Methods

`warn_for_todos` - Adds a warning if there are todos found in the modified code

`fail_for_todos` - Adds an error if there are todos found in the modified code

`print_todos_table` - Adds a list of offending files to the danger comment

`todos` - Returns the list of todos in the current diff set

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.


