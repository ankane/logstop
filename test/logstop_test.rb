require_relative "test_helper"

class LogstopTest < Minitest::Test
  def test_email
    assert_filtered "test@example.org"
    assert_filtered "TEST@example.org"
  end

  def test_phone
    assert_filtered "555-555-5555"
    assert_filtered "555 555 5555"
    assert_filtered "555.555.5555"
    refute_filtered "5555555555"
  end

  def test_credit_card
    assert_filtered "4242-4242-4242-4242"
    assert_filtered "4242 4242 4242 4242"
    assert_filtered "4242424242424242"
  end

  def test_ssn
    assert_filtered "123-45-6789"
    assert_filtered "123 45 6789"
    refute_filtered "123456789"
  end

  def test_ip
    refute_filtered "127.0.0.1"
    assert_filtered "127.0.0.1", ip: true
  end

  def test_url_password
    assert_filtered "https://user:pass@host", expected: "https://user:[FILTERED]@host"
    assert_filtered "https://user:pass@host.com", expected: "https://user:[FILTERED]@host.com"
  end

  def test_scrub
    assert_equal "[FILTERED]", Logstop.scrub("test@example.org")
  end

  def test_scrub_nil
    assert_equal "", Logstop.scrub(nil)
  end

  def test_multiple
    assert_filtered "test@example.org test2@example.org 123-45-6789", expected: "[FILTERED] [FILTERED] [FILTERED]"
  end

  def test_tagged_logging
    str = StringIO.new
    logger = ActiveSupport::Logger.new(str)
    logger = ActiveSupport::TaggedLogging.new(logger)
    Logstop.guard(logger)
    logger.tagged("Ruby") do
      logger.info "begin test@example.org end"
    end
    assert_equal "[Ruby] begin [FILTERED] end\n", str.string
  end

  def test_scubber
    scubber = lambda do |msg|
      msg.gsub(/hello/, "[FILTERED]")
    end

    assert_filtered "hello", scrubber: scubber
  end

  def test_formatter_immutable
    logger = Logger.new(StringIO.new)
    Logstop.guard(logger)
    str = "test@example.org"
    original_string = str.dup
    logger.info str
    assert_equal str, original_string
  end

  def test_scrub_immutable
    str = "test@example.org"
    original_string = str.dup
    Logstop.scrub(str)
    assert_equal str, original_string
  end

  private

  def log(msg, **options)
    str = StringIO.new
    logger = Logger.new(str)
    Logstop.guard(logger, **options)
    logger.info "begin #{msg} end"
    str.string.split(" : ", 2)[-1]
  end

  def assert_filtered(msg, expected: "[FILTERED]", **options)
    assert_equal "begin #{expected} end\n", log(msg, **options)
  end

  def refute_filtered(msg, **options)
    assert_filtered msg, expected: msg, **options
  end
end
