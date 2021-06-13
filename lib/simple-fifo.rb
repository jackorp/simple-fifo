libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'forwardable'

if RUBY_PLATFORM =~ /mswin/
  require 'web32/pipe'
  $POSIX = false
else
  $POSIX = true
end

require 'simple-fifo/fifo'
