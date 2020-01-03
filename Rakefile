require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test

namespace :benchmark do
  task :speed do
    require "bundler/setup"
    Bundler.require
    require "benchmark/ips"
    require "stringio"

    str = StringIO.new
    logger = ::Logger.new(str)
    Logstop.guard(logger)

    str2 = StringIO.new
    logger2 = ::Logger.new(str2)
    Logstop.guard(logger2, ip: true)

    Benchmark.ips do |x|
      x.report "no ipv6" do
        logger.info "This is a string"
      end

      x.report "ipv6" do
        logger2.info "This is a string"
      end
    end
  end

  task :memory do
    require "bundler/setup"
    Bundler.require
    require "memory_profiler"
    require "stringio"

    str = StringIO.new
    logger = ::Logger.new(str)

    str2 = StringIO.new
    logger2 = ::Logger.new(str2)
    Logstop.guard(logger2)

    print_options = {
      detailed_report: false,
      allocated_strings: 0,
      retained_strings: 0
    }

    report = MemoryProfiler.report do
      1000.times do
        logger.info "This is a string"
      end
    end
    puts "No Logstop"
    report.pretty_print(print_options)

    report = MemoryProfiler.report do
      1000.times do
        logger2.info "This is a string"
      end
    end
    puts "Logstop"
    report.pretty_print(print_options)
  end

  task :regexp do
    require "bundler/setup"
    Bundler.require
    require "benchmark/ips"
    require "stringio"

    msg = "I, [2018-12-10T14:49:12.209047 #56045]  INFO -- : This is a string"

    Benchmark.ips do |x|
      x.report "credit card" do
        msg.gsub(Logstop::CREDIT_CARD_REGEX, Logstop::FILTERED_STR)
      end
      x.report "email" do
        msg.gsub(Logstop::EMAIL_REGEX, Logstop::FILTERED_STR)
      end
      x.report "ip" do
        msg.gsub(Logstop::IP_REGEX, Logstop::FILTERED_STR)
      end
      x.report "phone" do
        msg.gsub(Logstop::PHONE_REGEX, Logstop::FILTERED_STR)
      end
      x.report "ssn" do
        msg.gsub(Logstop::SSN_REGEX, Logstop::FILTERED_STR)
      end
      x.report "url password" do
        msg.gsub(Logstop::URL_PASSWORD_REGEX, Logstop::FILTERED_URL_STR)
      end
    end
  end
end
