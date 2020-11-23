# typed: true
require 'sorbet-runtime'
require 'spud/driver'

module Spud
  class Watch
    extend T::Sig

    sig do
      params(
        driver: Driver,
        task: String,
        ordered: T::Array[String],
        named: T::Hash[String, String],
        watches: T::Array[String],
      ).void
    end
    def self.run!(driver:, task:, ordered:, named:, watches:)
      new(driver: driver, task: task, ordered: ordered, named: named, watches: watches).run!
    end

    sig do
      params(
        driver: Driver,
        task: String,
        ordered: T::Array[String],
        named: T::Hash[String, String],
        watches: T::Array[String],
      ).void
    end
    def initialize(driver:, task:, ordered:, named:, watches:)
      @driver = driver
      @task = task
      @ordered = ordered
      @named = named
      @watches = watches

      @last_changed = Time.at(0)
    end

    sig {void}
    def run!
      thread = T.let(nil, T.nilable(Thread))

      loop do
        if watches_changed?
          thread&.kill
          Process.kill('SIGKILL', T.must(@driver.subprocess_pid)) if @driver.subprocess_pid

          @last_changed = latest_watch_change
          thread = Thread.new { @driver.invoke(@task, @ordered, @named) }
        end

        sleep(0.1)
      end
    rescue Interrupt => error
      puts "handled interrupt #{error}" if @driver.debug?
    end

    sig {returns(T::Boolean)}
    def watches_changed?
      @last_changed < latest_watch_change
    end

    sig {returns(Time)}
    def latest_watch_change
      T.unsafe(Dir)[*@watches]
        .map(&File.method(:stat))
        .map(&:mtime)
        .max
    end
  end
end
