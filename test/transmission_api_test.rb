require_relative "test_helper"

class TransmissionApiTest < Test::Unit::TestCase
  def test_all
    transmission_api =
      TransmissionApi.new(
        :username => "username",
        :password => "password",
        :url      => "http://127.0.0.1:9091/transmission/rpc"
      )

    torrents = transmission_api.all

    puts "XXX: torrents: #{torrents}"
  end
end