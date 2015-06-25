require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*test.rb']
  t.verbose = true
end

task :default => [:gen_problems_test, :test]

task :gen_problems_test do
  File.open('test/problems_test.rb', 'w') do |f|
    erb = ERB.new(File.read('test/problems_test.rb.erb'))
    problem_names = Dir['test/problems/*.rb'].map do |f|
      File.basename(f).split('.').first
    end
    f.write(erb.result(binding))
  end
end
