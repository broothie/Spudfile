# typed: false
require 'stringio'
require 'spud/driver'
require 'spud/task_runners/spud_task_runner/shell/command'
require 'spud/task_runners/spud_task_runner/shell/result'

describe Spud::TaskRunners::SpudTaskRunner::Shell::Result do
  let(:driver) { Spud::Driver.new }
  let(:command) { 'echo "Hello, World!"' }
  subject(:result) do
    Spud::TaskRunners::SpudTaskRunner::Shell::Command.(driver, command, handle: StringIO.new)
  end

  it 'acts like a string' do
    expect(result).to be_a String
    expect(result).to eq "Hello, World!\n"
  end

  it 'acts like a Process::Status' do
    %i[exited? exitstatus pid signaled? stopped? stopsig success? termsig].each do |method|
      expect(result.respond_to?(method)).to be true
    end
  end
end
