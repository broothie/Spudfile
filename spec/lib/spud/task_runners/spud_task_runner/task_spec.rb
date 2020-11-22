# typed: false
require 'spud/task_runners/spud_task_runner/task'

describe Spud::TaskRunners::SpudTaskRunner::Task do
  let(:name) { 'task_name' }
  let(:filename) { File.join(path, basename) }
  subject(:qualified_name) { Spud::TaskRunners::SpudTaskRunner::Task.qualified_name(filename, name) }

  describe '.qualified_name' do
    context 'without path' do
      let(:path) { '' }

      context 'when file is Spudfile' do
        let(:basename)  { 'Spudfile' }

        it 'returns bare name' do
          expect(qualified_name).to eq 'task_name'
        end
      end

      context 'when file is not Spudfile' do
        let(:basename)  { 'tasks.spud' }

        it 'returns file-prefixed name' do
          expect(qualified_name).to eq 'tasks.task_name'
        end
      end
    end

    context 'with adjacent path' do
      let(:path) { './' }

      context 'when file is Spudfile' do
        let(:basename)  { 'Spudfile' }

        it 'returns bare name' do
          expect(qualified_name).to eq 'task_name'
        end
      end

      context 'when file is not Spudfile' do
        let(:basename)  { 'tasks.spud' }

        it 'returns file-prefixed name' do
          expect(qualified_name).to eq 'tasks.task_name'
        end
      end
    end

    context 'with path' do
      let(:path) { 'path/to' }

      context 'when file is Spudfile' do
        let(:basename)  { 'Spudfile' }

        it 'returns path-prefixed name' do
          expect(qualified_name).to eq 'path.to.task_name'
        end
      end

      context 'when file is not Spudfile' do
        let(:basename)  { 'tasks.spud' }

        it 'returns path-and-file-prefixed name' do
          expect(qualified_name).to eq 'path.to.tasks.task_name'
        end
      end
    end

    context 'with local path' do
      let(:path) { './path/to' }

      context 'when file is Spudfile' do
        let(:basename)  { 'Spudfile' }

        it 'returns path-prefixed name' do
          expect(qualified_name).to eq 'path.to.task_name'
        end
      end

      context 'when file is not Spudfile' do
        let(:basename)  { 'tasks.spud' }

        it 'returns path-and-file-prefixed name' do
          expect(qualified_name).to eq 'path.to.tasks.task_name'
        end
      end
    end
  end
end
