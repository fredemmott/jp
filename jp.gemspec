# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name          = 'jp'
  s.version       = '0.0.2'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Fred Emmott']
  s.email         = ['mail@fredemmott.co.uk']
  s.homepage      = 'https://github.com/fredemmott/jp'
  s.summary       = %q{Simple multi-language job pool system}
  s.description   = %q{Ruby components of jp - client and server}
  s.executables   = Dir['bin/*'].map{|x| File.basename(x)}
  s.require_paths = ['lib/rb']
  s.files         = Dir['bin/*'] + Dir['lib/rb/**/*']
  s.has_rdoc      = false

  s.add_dependency 'thrift', '~> 0.6.0'
  s.add_dependency 'mongo',  '~> 1.3.1'
  s.add_dependency 'rev',    '~> 0.3.2'
end
