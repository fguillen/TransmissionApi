require "minitest/autorun"
require "mocha/mini_test"
require_relative "../lib/transmission_api"

class Minitest::Test
  FIXTURES = File.expand_path( "#{File.dirname(__FILE__)}/fixtures" )

  def read_fixture( fixture_name )
    File.read( "#{FIXTURES}/#{fixture_name}" )
  end
end

