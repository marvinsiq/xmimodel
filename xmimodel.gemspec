require 'rake'
Gem::Specification.new do |s|
  s.name        = 'xmimodel'
  s.version     = '0.2.1'
  s.date        = '2014-07-11'
  s.summary     = "Xmi Model!"
  s.description = "A helper gem for working with XMI files"
  s.authors     = ["Marcus Siqueira"]
  s.email       = 'marvinsiq@gmail.com'
  s.files       = FileList['lib/*.rb', 'lib/**/*.rb'].to_a
  s.homepage    = 'https://github.com/marvinsiq/xmimodel'
end
