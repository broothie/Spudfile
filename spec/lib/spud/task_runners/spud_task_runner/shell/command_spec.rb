# typed: false
require 'sorbet-runtime'
require 'stringio'
require 'spud/driver'
require 'spud/task_runners/spud_task_runner/shell/command'

describe Spud::TaskRunners::SpudTaskRunner::Shell::Command do
  let(:handle) { StringIO.new }
  let(:silent) { false }
  let(:command) { 'echo "Hello, World!"' }
  let(:driver) { Spud::Driver.new }
  subject(:result) do
    Spud::TaskRunners::SpudTaskRunner::Shell::Command.(driver, command, silent: silent, handle: handle)
  end

  describe 'command issuing' do
    it 'works' do
      expect(result).to eq "Hello, World!\n"
      expect(handle.string).to eq "Hello, World!\n"
    end

    context 'when silent' do
      let(:silent) { true }

      it 'does not output to handle' do
        expect(result).to eq "Hello, World!\n"
        expect(handle.string).to be_empty
      end
    end
  end


  describe 'status' do
    context 'when successful' do
      it 'returns exit status 0' do
        expect(result.exitstatus).to be_zero
      end

      it 'has `success?`' do
        expect(result).to be_success
      end
    end

    context 'when error' do
      let(:command) { 'exit 1' }

      it 'returns the correct exit status' do
        expect(result.exitstatus).to eq 1
      end

      it 'does not have `success?`' do
        expect(result).not_to be_success
      end
    end
  end
end
