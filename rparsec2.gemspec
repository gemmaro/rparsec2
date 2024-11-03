require 'rake'

$LOAD_PATH << File.join(__dir__, "lib")
require_relative "lib/rparsec"

spec = Gem::Specification.new do |s|
  s.name = 'rparsec2'
  s.version = RParsec::VERSION
  s.summary = 'A Ruby Parser Combinator Framework'
  s.description = 'rparsec is a recursive descent parser combinator framework. Declarative API allows creating parser intuitively and dynamically.'
  s.author = 'Ben Yu'
  s.email = 'ajoo.email@gmail.com'
  s.license = "BSD-3-Clause"
  s.files = FileList['lib/**/*.rb']
  s.require_paths = ['lib']
  s.required_ruby_version = ">=3.1"

  homepage = "https://git.disroot.org/gemmaro/rparsec2"
  s.homepage = homepage
  s.metadata = {
    'rubygems_mfa_required' => 'true',
    'bug_tracker_uri'       => "#{homepage}/issues",
    'changelog_uri'         => "#{homepage}/src/branch/main/CHANGELOG.md",
    'documentation_uri'     => 'https://www.rubydoc.info/gems/rparsec2',
    'homepage_uri'          => homepage,
    'source_code_uri'       => homepage,
    'wiki_uri'              => "#{homepage}/wiki",
  }
end
