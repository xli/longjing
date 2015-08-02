require "bundler/gem_tasks"
require 'rake/testtask'
require 'longjing'

def pddl_problems
  Dir['test/domains/*.pddl'].each do |f|
    Longjing.pddl(f)
  end

  Dir['test/problems/*.pddl'].map do |f|
    prob = Longjing.pddl(f)
    {name: prob[:problem], prob: prob}
  end
end

def problems
  pddl_problems
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*test.rb']
  t.verbose = true
end

task :default => [:test, :benchmark]

task :profile do
  require 'ruby-prof'
  puts "Profile started"
  result = RubyProf.profile do
    problems.each do |prob|
      Longjing.plan(prob[:prob])
    end
  end
  puts "output: profile.html"
  printer = RubyProf::CallStackPrinter.new(result)
  File.open("profile.html", 'w') do |f|
    printer.print(f, {})
  end
end

task :b => :benchmark

task :benchmark do
  require 'benchmark'
  puts "Benchmark started, output: benchmark.log"
  stdout = STDOUT
  $stdout = File.new('benchmark.log', 'w')
  $stdout.sync = true
  label_len = problems.map{|p|p[:name].length}.max + 1
  Benchmark.benchmark(Benchmark::CAPTION, label_len, Benchmark::FORMAT, ">total:", ">avg:") do |x|
    bms = problems.map do |prob|
      x.report(prob[:name].to_s.ljust(20)) do
        10.times do
          Longjing.plan(prob[:prob])
        end
      end
    end
    [bms.reduce(:+), bms.reduce(:+)/bms.size]
  end
  $stdout = stdout
  puts File.read('benchmark.log')
end
