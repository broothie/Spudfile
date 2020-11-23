# typed: false
require 'stringio'

describe Spud::Shell::Result do
  let(:command) { 'echo "Hello, World!"' }
  subject(:result) do
    Spud::Shell::Command.(command, handle: StringIO.new)
  end

  it 'acts like a string' do
    expect(result).to be_a String
    expect(result).to eq "Hello, World!\n"
  end

  describe 'acts like a Process::Status' do
    %i[exited? exitstatus pid signaled? stopped? stopsig success? termsig].each do |method|
      it "implements #{method}" do
        expect(result.respond_to?(method)).to be true
      end
    end
  end
end
