require 'spec_helper'

RSpec.describe Fifo do
  let(:fifo_dir) { Dir.mktmpdir }
  let(:fifo_path) { File.join(fifo_dir, 'fifo_pipe') }
  after(:each)    { delete_data_dir }

  # Nukes the spec/data directory.
  def delete_data_dir
    FileUtils.rm_rf fifo_dir
  end

  context 'non-blocking' do
    let!(:path) { fifo_path }
    let(:writer)    { Fifo.new path, :w }
    let(:reader)    { Fifo.new path, :r }

    after { reader.close; writer.close }

    it 'is writable and readable' do
      writer.puts 'Hey!'
      expect(reader.gets).to eq "Hey!\n"
    end

    it 'is readable from another process' do
      writer.puts 'Hey!'

      fork do
        expect(reader.gets).to eq "Hey!\n"
      end

      Process.wait
    end

    it 'is writable from another process' do
      fork do
        writer.puts 'Hey!'
      end

      expect(reader.gets).to eq "Hey!\n"
    end

    it 'is writable and readable multiple times' do
      writer.puts 'Test 1'
      writer.puts 'Test 2'
      writer.puts 'Test 3'
      writer.puts 'Test 4'
      writer.puts 'Test 5'

      expect(reader.gets).to eq "Test 1\n"
      expect(reader.gets).to eq "Test 2\n"
      expect(reader.gets).to eq "Test 3\n"
      expect(reader.gets).to eq "Test 4\n"
      expect(reader.gets).to eq "Test 5\n"
    end

    it 'is readable with #readline' do
      writer.puts 'Hey!'
      expect(reader.readline).to eq "Hey!\n"
    end

    it 'gets characters one by one' do
      writer.puts '12345'
      expect(reader.read(1)).to eq '1'
      expect(reader.read(1)).to eq '2'
      expect(reader.read(1)).to eq '3'
      expect(reader.read(1)).to eq '4'
      expect(reader.read(1)).to eq '5'
    end

    describe '#getc' do
      it 'reads one character with' do
        writer.puts '12345'
        expect(reader.getc).to eq '1'
        expect(reader.getc).to eq '2'
        expect(reader.getc).to eq '3'
        expect(reader.getc).to eq '4'
        expect(reader.getc).to eq '5'
      end
    end

    describe '#read' do
      it 'reads multiple characters' do
        writer.puts '12345'
        expect(reader.read(2)).to eq '12'
        expect(reader.read(3)).to eq '345'
      end
    end

    it 'fails if the given file permission is incorrect' do
      expect { Fifo.new(fifo_path, :incorrect_perm, :nowait) }.to raise_error(RuntimeError, 'Unknown file permission. Must be either :r or :w.')
    end

    it 'fails if the given file mode is incorrect' do
      expect { Fifo.new(fifo_path, :r, :incorrect_mode) }.to raise_error(RuntimeError, 'Unknown file mode. Must be either :wait or :nowait for blocking or non-blocking respectively.')
    end
  end

  describe 'Blocking' do
    let!(:path) { fifo_path }
    it 'does not block when both ends opened, read first' do
      expect do
        Timeout.timeout(0.5) do
          fork do
            r = Fifo.new path, :r, :wait
            r.close
          end

          fork do
            w = Fifo.new path, :w, :wait
            w.close
          end

          Process.wait
        end
      end.not_to raise_error
    end

    it 'does not block when both ends opened, write first' do
      expect do
        Timeout.timeout(0.5) do
          fork do
            w = Fifo.new path, :w, :wait
            w.close
          end

          fork do
            r = Fifo.new path, :r, :wait
            r.close
          end

          Process.wait
        end
      end.not_to raise_error
    end

    it 'does block when only write end is open' do
      expect do
        Timeout.timeout(0.5) do
          w = Fifo.new path, :w, :wait
          w.close
        end
      end.to raise_error(Timeout::Error)
    end

    it 'does block when only read end is open' do
      expect do
        Timeout.timeout(0.5) do
          r = Fifo.new path, :r, :wait
          r.close
        end
      end.to raise_error(Timeout::Error)
    end
  end
end
