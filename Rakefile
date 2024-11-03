# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.libs << "test/src"
  t.test_files = FileList["test/src/*_test.rb"]
end

RDoc::Task.new do |rdoc|
  readme = "README.rdoc"
  rdoc.main = readme
  rdoc.rdoc_files.include("lib/**/*.rb", readme, "doc/*.rdoc", "CHANGELOG.md")
  rdoc.generator = "hanna"
end

task :gensig do
  sh 'typeprof', '-r', 'strscan', '-o', 'rparsec2.rbs', *Dir['lib/**/*.rb']
end
