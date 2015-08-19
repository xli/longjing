require "bundler/gem_tasks"
require 'rake/testtask'
require 'longjing'

def pddl_problems
  Dir['test/pddls/**/domain.pddl'].map do |f|
    Longjing.pddl(f)
  end
  Dir['test/pddls/**/*.pddl'].map do |f|
    if f =~ /domain.pddl/ || f =~ /barman/
      next
    end
    Longjing.pddl(f)
  end.compact
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*test.rb']
  t.verbose = true
end

task :default => [:test, :benchmark]

task :b => :benchmark

task :benchmark do
  require 'benchmark'
  puts "Benchmark started, output: benchmark.log"
  stdout = STDOUT
  $stdout = File.new('benchmark.log', 'w')
  $stdout.sync = true
  label_len = pddl_problems.map{|p|p[:problem].length}.max + 1
  Benchmark.benchmark(Benchmark::CAPTION, label_len, Benchmark::FORMAT, ">total:", ">avg:") do |x|
    bms = pddl_problems.map do |prob|
      x.report(prob[:problem].to_s.ljust(20)) do
        10.times do
          Longjing.plan(prob)
        end
      end
    end
    [bms.reduce(:+), bms.reduce(:+)/bms.size]
  end
  $stdout = stdout
  puts File.read('benchmark.log')
end
