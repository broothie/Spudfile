require 'stringio'
require 'spud/build_tools/spud/shell/command'
require 'spud/build_tools/spud/shell/result'

describe Spud::BuildTools::Spud::Shell::Result do
  subject(:result) { Spud::BuildTools::Spud::Shell::Command.('echo "Hello, World!"', handle: StringIO.new) }

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
