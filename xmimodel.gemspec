require 'rake'
Gem::Specification.new do |s|
  s.name        = 'xmimodel'
  s.version     = '0.1.0'
  s.date        = '2013-02-03'
  s.summary     = "Xmi Model!"
  s.description = "A helper gem for working with XMI files"
  s.authors     = ["Marcus Siqueira"]
  s.email       = 'marvinsiq@gmail.com'
  s.files       = FileList['lib/*.rb', 'lib/**/*.rb'].to_a
  s.homepage    = 'https://github.com/marvinsiq/xmimodel'
end