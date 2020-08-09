require 'rubygems'

Gem::Specification.new {|s|
    s.name                  = 'ruby-fifo'
    s.version               = '0.2.0'
    s.author                = ['shura', 'jackorp']
    s.email                 = 'shura1991@gmail.com'
    s.homepage              = 'http://github.com/jackorp/ruby-fifo'
    s.platform              = Gem::Platform::RUBY
    s.required_ruby_version = '>= 1.9.2'
    s.summary               = 'A cross-platform library to use named pipe'
    s.description           = s.summary
    s.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
    s.require_path          = 'lib'
    s.has_rdoc              = true
}
