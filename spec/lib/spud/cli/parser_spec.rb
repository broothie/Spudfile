require 'spud/cli/parser'

describe Spud::CLI::Parser do
  subject(:parser) { Spud::CLI::Parser.new(args) }
  let(:results) { parser.parse! }
  let(:task) { results.task }
  let(:options) { results.options }

  describe 'options' do
    context 'when valid args' do
      let(:args) { %w[-w server.rb -w index.html] }

      it 'parses options correctly' do
        expect(options.help?).to be false
        expect(options.watches).to include 'server.rb', 'index.html'
      end
    end

    context 'when invalid arg' do
      let(:args) { %w[-d] }

      it 'raises an error' do
        expect { results }.to raise_error(Spud::Error, "spud: invalid option: '-d'")
      end
    end
  end

  describe 'task' do
    context 'without options or args' do
      let(:args) { %w[clean] }

      it 'gets the right task name' do
        expect(task).to eq 'clean'
      end
    end

    context 'with options' do
      let(:args) { %w[-w server.rb run] }

      it 'gets the task name and options' do
        expect(options.watches).to include 'server.rb'
        expect(task).to eq 'run'
      end
    end

    context 'with args' do
      let(:args) { %w[-w server.rb run dev --code 555 no-db] }

      it 'gets everything' do
        expect(options.watches).to include 'server.rb'
        expect(task).to eq 'run'
        expect(results.positional).to include 'dev', 'no-db'
        expect(results.named).to include 'code' => '555'
      end
    end
  end
end
