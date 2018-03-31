require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test

task :benchmark do
  require "bundler/setup"
  Bundler.require
  require "benchmark/ips"

  str = StringIO.new
  logger = ::Logger.new(str)

  str2 = StringIO.new
  logger2 = ::Logger.new(str2)
  logger2.formatter = Logstop::Formatter.new

  Benchmark.ips do |x|
    x.report "logger" do
      logger.info "This is a string: test@test.com"
    end

    x.report "logger2" do
      logger2.info "This is a string: test@test.com"
    end
  end
end
