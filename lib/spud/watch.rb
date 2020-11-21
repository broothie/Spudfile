module Spud
  class Watch
    def self.run!(task:, positional:, named:, watches:)
      new(task: task, positional: positional, named: named, watches: watches).run!
    end

    def initialize(task:, positional:, named:, watches:)
      @task = task
      @positional = positional
      @named = named
      @watches = watches

      @last_changed = Time.at(0)
    end

    def run!
      thread = nil

      loop do
        if watches_changed?
          thread&.kill
          puts status: thread&.status

          @last_changed = latest_watch_change
          thread = Thread.new { Runtime.invoke(@task, @positional, @named) }
        end

        sleep(0.1)
      end
    rescue SystemExit, Interrupt => error
      puts "handled #{error}" if Runtime.debug?
    end

    def watches_changed?
      @last_changed < latest_watch_change
    end

    def latest_watch_change
      Dir[*@watches]
        .map(&File.method(:stat))
        .map(&:mtime)
        .max
    end
  end
end
