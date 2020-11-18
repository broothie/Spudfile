require 'tempfile'
require 'securerandom'
require 'spud/build_tools/spud/dependency'

describe Spud::BuildTools::Spud::Dependency do
  def close_all(*files)
    files.each { |file| file.is_a?(Array) ? close_all(*file) : file.close }
  end

  it 'says up to date when target after source' do
    source = Tempfile.new('source')
    target = Tempfile.new('target')
    close_all(source, target)

    dependency = Spud::BuildTools::Spud::Dependency.new(source.path, target.path)
    expect(dependency.up_to_date?).to be true
  end

  it 'says up to date when multiple targets after multiple sources' do
    sources = [Tempfile.new('source_1'), Tempfile.new('source_2')]
    targets = [Tempfile.new('target_1'), Tempfile.new('target_2')]
    close_all(sources, targets)

    dependency = Spud::BuildTools::Spud::Dependency.new(sources.map(&:path), targets.map(&:path))
    expect(dependency.up_to_date?).to be true
  end

  it 'says up to date when source files do not exist' do
    dependency = Spud::BuildTools::Spud::Dependency.new(SecureRandom.hex, SecureRandom.hex)
    expect(dependency.up_to_date?).to be true
  end

  it 'says needs update when source updated after target' do
    source = Tempfile.new('source')
    target = Tempfile.new('target')
    source.puts 'info'
    close_all(source, target)

    dependency = Spud::BuildTools::Spud::Dependency.new(source.path, target.path)
    expect(dependency.need_to_update?).to be true
  end

  it 'says need update when source created after target' do
    target = Tempfile.new('target')
    source = Tempfile.new('source')
    close_all(target, source)

    dependency = Spud::BuildTools::Spud::Dependency.new(source.path, target.path)
    expect(dependency.need_to_update?).to be true
  end

  it 'says need update when target does not exist' do
    source = Tempfile.new('source')
    close_all(source)

    dependency = Spud::BuildTools::Spud::Dependency.new(source.path, SecureRandom.hex)
    expect(dependency.need_to_update?).to be true
  end
end
