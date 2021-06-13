require 'rspec/core/rake_task'

task :default => [:spec]

desc "Run all tests."
RSpec::Core::RakeTask.new(:spec)

desc "Opens up an irb session with the load path and library required."
task :console do
  exec "irb -I lib/ -r ./lib/simple-fifo.rb"
end

desc "Alias for rake console."
task :c => [:console]
