# `spud`

Spud is a build tool, written as a [ruby](https://www.ruby-lang.org) [DSL](https://en.wikipedia.org/wiki/Domain-specific_language).

- [Installation](#installation)
- [Description](#description)
- [Spec](#Spec)
- [Planned Features](#planned-features)

## Installation

### Via RubyGems

```shell script
$ gem install spud
```

## Description

Rules are written in a `Spudfile`. A simple rule to build a Go program might look like this:
```ruby
# Build `api` if any Go files have changed
build '**/*.go' => 'api' do
  go 'generate ./...'
  go 'build -o api cmd/api/main.go'
end
```

Then, to run this rule from your shell: 
```shell script
$ spud build
````

Here's a contrived example of more features:
```ruby
# File dependencies are declared as sets of files which build other files
# Block params declared for a rule can be passed in from the command line
publish ['**/*.rb', 'spud.gemspec'] => 'spud-*.gem' do |version, m: 'updates'|
  # `invoke` can be used to invoke other rules
  invoke :test
  invoke :clean
  
  # Commands that don't collide with global methods can be issued by name
  git 'add -A'
  git 'commit -m', q(m)
  git 'push'

  # Command names that *do* collide can be issued with `sh`. There are 3 levels of noisiness:
  sh 'gem build spud.gemspec'
  shh "gem install spud-#{version}.gem"
  shhh "gem push spud-#{version}.gem"
end

# `rule` can be used to declare a rule if the rule name is going to collide with a global method
rule :test do |package = './...'|
  go "test #{package} -coverprofile=.cov"
end

clean do
  # `sh?` is a version of `sh` that won't quit the rule on error. There's also the quieter `shh?` and `shhh?`
  sh? 'rm -rf api .cov'
end
```

Another cool feature is that Spudfiles integrate with Makefiles. This way you can drop a Spudfile in next to a Makefile and
use all of your existing make rules. For example:
```makefile
# Makefile
clean:
    rm -rf bin %.log
```

```ruby
# Spudfile
build do
  invoke :clean # This will invoke rule `clean` from the Makefile
  go 'build -o bin main.go'    
end
```

## Spec

```ruby
rule_name *files, ['dependencies'] => ['targets'] do |required, optional = 'default', keyword: 'default'|
  command *strings  # Issues a shell command

  sh *strings     # Issues a shell command
  shh *strings    # Issues a shell command without echoing the command
  shhh *strings   # Issues a silent command
  
  # The following do the same as above, but won't kill the rule if their command fails
  sh? *strings
  shh? *strings
  shhh? *strings
  
  q(string)   #=> 'string' (wraps a string in single quotes - helpful when issuing commands)
  qq(string)  #=> "string" (wraps a string in double quotes ...)
  
  invoke rule_name, *args   # Invokes another rule
end

```

## Planned Features

- [x] Command line options
- [x] Named rule args
- [ ] Rule watching
- [ ] Rule dependency chaining (like Makefiles)
- [ ] Deeper make integration
- [ ] Split script into multiple files
