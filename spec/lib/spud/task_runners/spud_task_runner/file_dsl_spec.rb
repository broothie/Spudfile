# typed: false
require 'tempfile'

describe Spud::TaskRunners::SpudTaskRunner::FileDSL do
  let(:driver) { Spud::Driver.new }
  let(:tasks) { Spud::TaskRunners::SpudTaskRunner::FileDSL.run(driver, file.path) }
  let(:file) do
    f = Tempfile.new('Spudfile')
    f.write(contents)
    f.close
    f
  end

  context 'when explicit tasks' do
    let(:contents) do
      <<-RUBY
        task 'greet' do
          sh 'echo hello'
        end

        task 'thing' do
          puts 'thing'
        end
      RUBY
    end

    it 'registers tasks' do
      expect(tasks.length).to eq 2

      task = tasks.first
      expect(task.name).to include 'Spudfile'
      expect(task.name).to end_with 'greet'
    end
  end

  context 'when bare tasks' do
    let(:contents) do
      <<-RUBY
        greet 'index.md' => 'index.html' do |a, b = '1', c:, d: '4'|
          sh 'echo hello'
        end
      RUBY
    end

    it 'registers tasks' do
      expect(tasks.length).to eq 1

      task = tasks.first
      expect(task.name).to include 'Spudfile'
      expect(task.name).to end_with 'greet'
    end

    it 'registers args' do
      task = tasks.first
      expect(task.args.length).to eq 4
      expect(task.args[0].name).to eq 'a'
      expect(task.args[0]).to be_ordered
      expect(task.args[0]).to be_required

      expect(task.args[1].name).to eq 'b'
      expect(task.args[1]).to be_ordered
      expect(task.args[1]).to_not be_required

      expect(task.args[2].name).to eq 'c'
      expect(task.args[2]).to be_named
      expect(task.args[2]).to be_required

      expect(task.args[3].name).to eq 'd'
      expect(task.args[3]).to be_named
      expect(task.args[3]).to_not be_required
    end

    it 'registers dependencies' do
      task = tasks.first
      expect(task).to be_a(Spud::TaskRunners::SpudTaskRunner::Task)
      expect(task.dependencies.length).to eq 1
      expect(task.dependencies.first.sources).to eq ['index.md']
      expect(task.dependencies.first.targets).to eq ['index.html']
    end
  end
end
