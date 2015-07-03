require "bundler/gem_tasks"
require 'rake/testtask'
require 'longjing'

def problems
  Dir['test/problems/*.rb'].map do |f|
    require_relative f
    name = File.basename(f).split('.').first
    {name: name, method: name + "_problem"}
  end
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*test.rb']
  t.verbose = true
end

task :default => [:gen_problems_test, :test, :benchmark]

task :gen_problems_test do
  File.open('test/problems_test.rb', 'w') do |f|
    erb = ERB.new(File.read('test/problems_test.rb.erb'))
    problem_names = problems.map{|p| p[:name]}
    f.write(erb.result(binding))
  end
end

task :profile do
  require 'ruby-prof'
  puts "Profile started"
  [:breadth_first].each_with_index do |strategy, index|
    result = RubyProf.profile do
      problems.each do |prob|
        Longjing.plan(send(prob[:method]), strategy)
      end
    end
    puts "output: profile_#{strategy}.html"
    printer = RubyProf::GraphHtmlPrinter.new(result)
    File.open("profile_#{strategy}.html", 'w') do |f|
      printer.print(f, {})
    end
  end
end

task :benchmark do
  require 'benchmark'
  puts "Benchmark started, output: benchmark.log"
  stdout = STDOUT
  $stdout = File.new('benchmark.log', 'w')
  $stdout.sync = true
  label_len = problems.map{|p|p[:name].length}.max + 1
  Benchmark.benchmark(Benchmark::CAPTION, label_len, Benchmark::FORMAT, ">total:", ">avg:") do |x|
    bms = problems.map do |prob|
      x.report(prob[:name].ljust(20)) do
        Longjing.plan(send(prob[:method]))
      end
    end
    [bms.reduce(:+), bms.reduce(:+)/bms.size]
  end
  $stdout = stdout
  puts File.read('benchmark.log')
end
