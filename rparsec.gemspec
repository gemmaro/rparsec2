require 'rake'
spec = Gem::Specification.new do |s|
  s.name = 'rparsec'
  s.version = '1.0'
  s.summary = 'A Ruby Parser Combinator Framework'
  s.description = 'rparsec is a recursive descent parser combinator framework. Declarative API allows creating parser intuitively and dynamically.'
  s.author = 'Ben Yu'
  s.email = 'ajoo.email@gmail.com'
  s.license = "BSD-3-Clause"
  s.files = FileList['lib/**/*.rb']
  s.require_paths = ['lib']
  s.metadata['rubygems_mfa_required'] = 'true'
  s.required_ruby_version = ">=3.1"
end
