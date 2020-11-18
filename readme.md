# `spud` 🥔

Spud is a task runner, in the form of a [ruby](https://www.ruby-lang.org) [DSL](https://en.wikipedia.org/wiki/Domain-specific_language).

- [Installation](#installation)
- [Usage](#usage)
- [Why?](#why)
- [Spec](#spec-by-example)
- [Planned Features](#todo)

## Installation

```shell script
$ gem install spud
```

## Usage

Tasks are defined in a `Spudfile`:
```ruby
# Spudfile
clean do
  # Issue a shell command
  sh 'rm -rf .byebug_history .spec_status'
end

# Block args == command line args:
spec do |path = 'spec/lib/spud'|
  sh "bundle exec rspec #{path}"
end

# You can ask for positional, optional, and named args:
greet do |name, greeting = 'Hello', comma: 'yes'|
  comma = comma == 'yes' ? ',' : ''
  puts "#{greeting}#{comma} #{name}"
end
```

To list all tasks and their args, run spud without any arguments:
```shell script
$ spud
clean
spec    <path=spec/lib/spud>
greet   <name> <greeting=Hello>  --comma=yes
```

Then, to run the `greet` task from your shell: 
```shell script
$ spud greet Alice --comma no
Hello Alice
````

## Spec by Example

```ruby
# A task with 4 arguments:
# - 1 required positional
# - 1 optional positional
# - 1 required named
# - 1 optional named
# and invoked with: 
# $ spud fancy --d four -c three one 
#=> ["one", "2", "three", "four"]
fancy do |a, b = '2', c:, d: '4'|
  p [a, b, c, d]
end

# A task issuing some shell commands
shelly do
  sh 'echo hello'    # Prints the output of 'echo hello', prints 'echo hello' first (like in Make)
  shh 'echo hello'   # Prints the output of 'echo hello', doesn't print 'echo hello' first
  shhh 'echo hello'  # No output is printed at all

  sh! 'exit 1'  # Runs the shell command, and raises an error if it fails. Equivalents are available for shh! and shhh!

  result = shhh 'which spud'  # Returns a String-like object that also acts like a Process::Status
  puts result                 #=> '/path/to/your/spud'
  puts result.success?        #=> true
  puts result.exitstatus      #=> 0
end

# An unconventionally named task invoking other tasks
task 'call-others' do
  # All of the following invoke the task `shelly`
  shelly            # Straight up
  invoke 'shelly'   # Via a string
  invoke :shelly    # Symbols work too
  invoke! :shelly   # Will raise an error if task `shelly` fails

  # Calling tasks with arguments
  fancy 'one', c: 'three'
end
```

## Why?

### Rake

We already have Rake right? I love Rake - it's powerful and reliable. My main issue with Rake is the argument syntax.

To me,

```ruby
greet do |name = 'Alice'|
  puts "Hello #{name}"
end
```

```shell script
$ spud greet Bob
```

looks better than

```ruby
task :greet, [:name] do |t, args|
  puts "Hello #{args.fetch(:name, 'Alice')}"
end
```

```shell script
$ rake greet\[Bob\]
# or
$ rake 'greet[Bob]'
```

### Make

Make is great too. That's why `spud` is integrated with make, as well as some other task-like tools. 

I like this mainly because then you can list make rules:

```shell script
$ ls
Makefile package.json
$ spud
bundle  package.json
all     Makefile
```

But you can issue them with `spud` as well. 

```shell script
$ spud all
echo building stuff...
building stuff...
$ spud bundle
yarn run v1.22.5
webpack index.js
✨  Done in 0.06s.
```

## TODO

- [ ] Better spec coverage
- [ ] File dependencies
- [ ] Task watching
- [ ] Rake integration
- [ ] docker-compose integration
