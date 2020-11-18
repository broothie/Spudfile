# `spud`

Spud is a task runner, in the form of a [ruby](https://www.ruby-lang.org) [DSL](https://en.wikipedia.org/wiki/Domain-specific_language).

- [Installation](#installation)
- [Description](#usage)
- [Spec](#spec)
- [Planned Features](#todo)

## Installation

```shell script
$ gem install spud
```

## Usage

Rules are written in a `Spudfile`. A simple `Spudfile` might look like this:
```ruby
# A task called `clean`
clean do
  # A shortcut for shelling out
  sh 'rm -rf .byebug_history .spec_status'
end

# Adding args to the block adds args to the task
spec do |path = 'spec/lib/spud'|
  sh "bundle exec rspec #{path}"
end

# You can ask for positional, optional, and named args
greet do |name, greeting = 'Hello', comma: 'yes'|
  comma = comma == 'yes' ? ',' : ''
  puts "#{greeting}#{comma} #{name}"
end
```

To list all tasks and their args, run spud without any arguments:
```shell script
$ spud
spec                 <path=spec/lib/spud>
create
clean
greet                <name> <greeting=Hello>  --comma=yes
```

Then, to run the `greet` rule from your shell: 
```shell script
$ spud greet Andrew --comma no
Hello Andrew
````

## Spec

```ruby
# A task with 4 arguments:
# - 1 required positional
# - 1 optional positional
# - 1 required named
# - 1 optional named
# and called with: 
# $ spud fancy --d four -c three one 
#=> ["one", "2", "three", "four"]
fancy do |a, b = '2', c:, d: '4'|
  p [a, b, c, d]
end

# A task issuing some shell commands
shelly do
  sh 'echo hello'    # Prints the output of 'echo hello', prints 'echo hello' first (like in Make)
  shh 'echo hello'   # Prints the output of 'echo hello', doesn't print 'echo hello first
  shhh 'echo hello'  # Prints the output of 'echo hello', no output is printed at all

  sh! 'exit 1'  # Runs the shell command, and raises an error if it fails. Equivalents are available for shh! and shhh!

  result = shhh 'which spud'  # Returns a String like object that also acts like a Process::Status
  puts result                 #=> '/Users/you/.rbenv/shims/spud'
  puts result.success?        #=> true
  puts result.exitstatus      #=> 0
end

# An explicitly defined task invoking other tasks
task 'call-others' do
  # All of the following invoke the task `shelly`
  shelly
  invoke :shelly
  invoke 'shelly'
  invoke! 'shelly'

  # Calling tasks with arguments
  fancy 'one', c: 'three'
end
```

## TODO

- [ ] Fuller spec coverage
- [ ] Rule watching
