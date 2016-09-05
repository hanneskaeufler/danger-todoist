[![Build Status](https://travis-ci.org/hanneskaeufler/danger-todoist.svg?branch=master)](https://travis-ci.org/hanneskaeufler/danger-todoist) [![Gem Version](https://badge.fury.io/rb/danger-todoist.svg)](https://badge.fury.io/rb/danger-todoist)

# danger-todoist

A description of danger-todoist.

## Installation

    $ gem install danger-todoist

## Usage

    Methods and attributes from this plugin are available in
    your `Dangerfile` under the `todoist` namespace.

### todoist

<blockquote>Ensure there are no TODOS left in the modified code
  <pre>
todoist.warn_for_todos</pre>
</blockquote>

<blockquote>Set custom warning message
  <pre>
todois.message = "Please fix all TODOS"
todoist.warn_for_todos</pre>
</blockquote>

<blockquote>List every todo item
  <pre>
todoist.warn_for_todos
todoist.print_todos_table</pre>
</blockquote>

#### Attributes

`message` - Message to be shown

#### Methods

`warn_for_todos` - Adds a warning if there are todos found in the modified code

`print_todos_table` - Adds a list of offending files to the danger comment

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.


