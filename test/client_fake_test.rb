require_relative "test_helper"

class ClientFakeTest < Test::Unit::TestCase
  def setup
    @client = TransmissionApi::ClientFake.new({})
  end

  def test_all
    assert_equal( "77831ec368308f1031434c5581a76fd0c3e06cfd", @client.all.first["hashString"] )
  end

  def test_find
    assert_equal( "77831ec368308f1031434c5581a76fd0c3e06cfd", @client.find("77831ec368308f1031434c5581a76fd0c3e06cfd")["hashString"] )
  end

  def test_create
    Digest::MD5.expects(:hexdigest).returns("WADUS-HASH")
    assert_equal( "WADUS-HASH", @client.create("filename")["hashString"] )
  end

  def test_destroy
    torrents = [
      { "hashString" => "A" },
      { "hashString" => "B" },
      { "hashString" => "C" },
    ]

    @client.expects(:torrents).returns(torrents)

    @client.destroy("B")

    assert_equal(["A", "C"], torrents.map{ |e| e["hashString"] })
  end

end