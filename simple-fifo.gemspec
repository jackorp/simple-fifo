require 'rubygems'

Gem::Specification.new { |s|
  s.name                  = 'simple-fifo'
  s.version               = '1.0.0'
  s.author                = ['shura', 'jackorp']
  s.email                 = 'jar.prokop@volny.cz'
  s.homepage              = 'http://github.com/jackorp/simple-fifo'
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'
  s.summary               = 'A cross-platform library to use named pipe'
  s.description           = 'A FIFO library making I/O operations on FIFO files simple.'
  s.files                 = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.require_path          = 'lib'
  s.has_rdoc              = true
}
