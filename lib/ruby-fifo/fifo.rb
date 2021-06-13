class Fifo
  # Module to allow delegation
  include Forwardable

  # Constructs a new Fifo. Can open either a read or write fifo in either
  # blocking or non-blocking mode.
  #
  # Examples:
  #
  #   # Non-blocking read Fifo (default)
  #   r = Fifo.new('path/to/fifo')
  #
  #   # Blocking read Fifo
  #   r = Fifo.new('path/to/fifo', :r, :wait)
  #
  #   # Non blocking write Fifo
  #   w = Fifo.new('path/to/fifo', :w, :nowait)
  def initialize(file, perms = :r, mode = :nowait)
    raise 'Unknown file permission. Must be either :r or :w.' unless [:r, :w].include?(perms)

    unless [:wait, :nowait].include?(mode)
      raise 'Unknown file mode. Must be either :wait or :nowait for blocking' \
            ' or non-blocking respectively.'
    end

    if $POSIX
      unless File.exist?(file)
        File.mkfifo(file)
        File.chmod(0o0666, file)
      end

      perms = perms.to_s + (mode == :wait ? '' : '+')
      @pipe = open_pipe(file, perms)
    else
      include Win32

      mode  = mode  == :wait ? Pipe::WAIT : Pipe::NOWAIT
      @pipe = perms == :r ? Pipe.new_server(file, mode) : Pipe.new_client(file)
      @pipe.connect if perms == :r
    end

    def_delegators :@pipe, :read, :write, :close, :to_io, :flush
  end

  # Prints the arguments passed in to the fifo. to_s is called on either
  # argument passed in.
  #
  # Example:
  #
  #   f = Fifo.new('path/to/fifo', :w)
  #   f.print "Hello!"
  #   f.print "Multiple", "Arguments"
  #   f.puts "!" # Need a puts because fifos are line buffered
  #
  #   r = Fifo.new('path/to/fifo', :r)
  #   r.gets
  #   #=> "Hello!MultipleArugments!\n"
  def print(*args)
    args.each do |obj|
      self.write obj.to_s
    end

    write $OUTPUT_RECORD_SEPARATOR
    flush
  end

  # Works the same as Kernel::puts, writes a string or multiple strings to the
  # Fifo and then appends a new line. In the case of multiple arguments, a new
  # line is printed after each one.
  #
  # Examples:
  #
  #   w = Fifo.new('path/to/fifo', :w)
  #   r = Fifo.new('path/to/fifo', :r)
  #
  #   w.puts "1", "2", "3", "4"
  #
  #   r.gets
  #   #=> "1\n"
  #
  #   r.gets
  #   #=> "2\n"
  #
  #   r.gets
  #   #=> "3\n"
  #
  #   r.gets
  #   #=> "4\n"
  def puts(*args)
    args.each do |obj|
      self.write "#{obj.to_s.sub(/\n$/, '')}\n"
      flush
    end
  end

  # Reads a single character
  #
  # Alias for read(1).
  def getc
    self.read(1)
  end

  # Works in the same way as gets does but uses the $_ global variable for
  # reading in each character. There is no functional difference between this
  # and gets.
  def readline
    str = ''
    while ($_ = self.read(1)) != "\n"
      str << $_
    end
    str << "\n"
  end

  # Reads from the Fifo until it encounters a new line. Will block the current
  # thread of execution until it hits a new line. This includes when the fifo is
  # empty and nothing is writing to it.
  #
  # Example:
  #
  #   w = Fifo.new('path/to/fifo', :w)
  #   r = Fifo.new('path/to/fifo', :r)
  #
  #   w.puts "Hello, world!"
  #   r.gets
  #   #=> "Hello, world!\n"
  def gets
    self.readline
  end

  private

  def open_pipe(file, perms)
    File.open(file, perms)
  rescue Errno::EINTR
    # We just want to open a file, so keep retrying.
    # Inspired by golang's solution: https://github.com/golang/go/commit/50d0ee0c98ea21f818d2daa9bc21ef51861a2ef9
    retry
  end
end
