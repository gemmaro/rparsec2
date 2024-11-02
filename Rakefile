require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.test_files = FileList["test/src/*_test.rb"]
end

RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include("lib/**/*.rb")
end

task :gensig do
  sh 'typeprof', '-r', 'strscan', '-o', 'rparsec2.rbs', *Dir['lib/**/*.rb']
end
