require_relative "test_helper"

class LogstopTest < Minitest::Test
  def test_email
    assert_filtered "test@example.org"
    assert_filtered "test123@example.org"
    assert_filtered "TEST@example.org"
    assert_filtered "test@sub.example.org"
    assert_filtered "test@sub.sub2.example.org"
    assert_filtered "test+test@example.org"
    assert_filtered "test.test@example.org"
    assert_filtered "test-test@example.org"
    assert_filtered "test@example.us"
    assert_filtered "test@example.science"
    refute_filtered "test@example.org", email: false
  end

  def test_phone
    assert_filtered "555-555-5555"
    assert_filtered "555 555 5555"
    assert_filtered "555.555.5555"
    refute_filtered "5555555555"
    refute_filtered "555-555-5555", phone: false

    # use 7 digit min
    # https://stackoverflow.com/questions/14894899/what-is-the-minimum-length-of-a-valid-international-phone-number
    refute_filtered "+123456"
    assert_filtered "+1234567"
    assert_filtered "+15555555555"
    assert_filtered "+123456789012345"
    refute_filtered "+1234567890123456"
  end

  def test_credit_card
    assert_filtered "4242-4242-4242-4242"
    assert_filtered "4242 4242 4242 4242"
    assert_filtered "4242424242424242"
    refute_filtered "0242424242424242"
    refute_filtered "55555555-5555-5555-5555-555555555555" # uuid
    refute_filtered "4242-4242-4242-4242", credit_card: false
  end

  def test_ssn
    assert_filtered "123-45-6789"
    assert_filtered "123 45 6789"
    refute_filtered "123456789"
    refute_filtered "123-45-6789", ssn: false
  end

  def test_ip
    refute_filtered "127.0.0.1"
    assert_filtered "127.0.0.1", ip: true
  end

  def test_url_password
    assert_filtered "https://user:pass@host", expected: "https://user:[FILTERED]@host"
    assert_filtered "https://user:pass@host.com", expected: "https://user:[FILTERED]@host.com"
    refute_filtered "https://user:pass@host", url_password: false
    refute_filtered "https://host:80/test@", encoded: false
  end

  def test_mac
    refute_filtered "ff:ff:ff:ff:ff:ff"
    assert_filtered "ff:ff:ff:ff:ff:ff", mac: true
    assert_filtered "a1:b2:c3:d4:e5:f6", mac: true
    assert_filtered "A1:B2:C3:D4:E5:F6", mac: true
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

  def test_order
    assert_filtered "123-45-6789@example.org"
    assert_filtered "127.0.0.1@example.org", ip: true
  end

  def test_tagged_logging
    require "active_support/all"

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
    assert_equal original_string, str
  end

  def test_scrub_immutable
    str = "test@example.org"
    original_string = str.dup
    Logstop.scrub(str)
    assert_equal original_string, str
  end

  private

  def log(msg, **options)
    str = StringIO.new
    logger = Logger.new(str)
    Logstop.guard(logger, **options)
    logger.info "begin #{msg} end"
    str.string.split(" : ", 2)[-1]
  end

  def assert_filtered(msg, expected: "[FILTERED]", encoded: true, **options)
    assert_equal "begin #{expected} end\n", log(msg, **options)
    assert_equal "begin #{expected} end\n", URI.decode_www_form_component(log(URI.encode_www_form_component(msg), **options)) if encoded
  end

  def refute_filtered(msg, **options)
    assert_filtered msg, expected: msg, **options
  end
end
