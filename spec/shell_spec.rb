RSpec.describe Spud::Shell do
  it 'captures the output' do
    out = Spud::Shell.('echo omg', silent: true)
    out.wait!
    expect(out).to eq "omg\n"
  end

  it 'captures multi-line output' do
    filename = 'asdf.txt'
    lines = "line 1 \nline 2\n"

    File.write(filename, lines)

    out = Spud::Shell.("cat #{filename}", silent: true)
    expect(out).to eq lines

    File.delete(filename)
  end

  describe '.async' do
    it 'can be waited upon' do
      seconds = 1
      after = Time.now + seconds

      out = Spud::Shell.async("sleep #{seconds}")
      out.wait!
      expect(Time.now).to be > after
    end

    it 'can be killed' do
      seconds = 60
      after = Time.now + seconds

      out = Spud::Shell.async("sleep #{seconds}")
      out.kill!
      out.wait!
      expect(Time.now).to be < after
    end

    it 'can return a process object' do
      out = Spud::Shell.async("sleep 1; echo omg", silent: true)
      expect(out).to be_empty
      out.wait!
      expect(out).to eq "omg\n"
    end
  end
end
