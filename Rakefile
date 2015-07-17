require "bundler/gem_tasks"
require 'rake/testtask'
require 'longjing'

def pddl_problems
  Dir['test/domains/*.pddl'].each do |f|
    Longjing.load(f)
  end

  Dir['test/problems/*.pddl'].map do |f|
    prob = Longjing.load(f)
    {name: prob[:problem], prob: prob}
  end
end

def internal_format_problems
  Dir['test/problems/*.rb'].map do |f|
    require_relative f
    name = File.basename(f).split('.').first
    {name: name, prob: send(name + "_problem")}
  end
end

def problems
  internal_format_problems + pddl_problems
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
    problem_names = internal_format_problems.map{|p| p[:name]}
    f.write(erb.result(binding))
  end
end

task :profile do
  require 'ruby-prof'
  puts "Profile started"
  result = RubyProf.profile do
    problems.each do |prob|
      Longjing.plan(prob[:prob])
    end
  end
  puts "output: profile.html"
  printer = RubyProf::GraphHtmlPrinter.new(result)
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
      x.report(prob[:name].ljust(20)) do
        Longjing.plan(prob[:prob])
      end
    end
    [bms.reduce(:+), bms.reduce(:+)/bms.size]
  end
  $stdout = stdout
  puts File.read('benchmark.log')
end


task :barman do
  Longjing::PDDL.parse(File.read('test/domains/barman.pddl'))
  prob = Longjing.problem(Longjing::PDDL.parse(File.read("test/barman-p2-10-4-13.pddl")))

  require 'benchmark'
  Benchmark.bm do |x|
    x.report do
      graph = Longjing::FF::RelaxedGraphPlan.new(prob)
      graph.extract(prob.initial)
      graph.extract(prob.initial)
      graph.extract(prob.initial)
      graph.extract(prob.initial)
      graph.extract(prob.initial)
    end
  end
  require 'ruby-prof'
  result = RubyProf.profile do
    graph = Longjing::FF::RelaxedGraphPlan.new(prob)
    graph.extract(prob.initial)
    graph.extract(prob.initial)
    graph.extract(prob.initial)
    graph.extract(prob.initial)
    graph.extract(prob.initial)
  end
  puts "output: profile.html"
  printer = RubyProf::GraphHtmlPrinter.new(result)
  File.open("profile.html", 'w') do |f|
    printer.print(f, {})
  end
end
