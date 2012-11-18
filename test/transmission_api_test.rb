require_relative "test_helper"

class TransmissionApiTest < Test::Unit::TestCase
  def setup
    @transmission_api = TransmissionApi.new( :url => "http://api.url" )
  end

  def test_post
    @transmission_api.stubs(:session_id).returns("SESSION-ID")
    @transmission_api.stubs(:url).returns("http://api.url")

    opts = { :key1 => "value1", :key2 => "value2" }

    opts_expected = {
      :body => { :key1 => "value1", :key2 => "value2" }.to_json,
      :headers => { "x-transmission-session-id" => "SESSION-ID" }
    }

    response_mock =
      stub(
        :code => "",
        :message => "",
        :headers => "",
        :body => {"key" => "value"}.to_json
      )

    HTTParty.expects(:post).with( "http://api.url", opts_expected ).returns( response_mock )

    assert_equal "value", @transmission_api.post(opts)["key"]
  end

  def test_post_with_basic_auth
    @transmission_api.stubs(:session_id).returns("SESSION-ID")
    @transmission_api.stubs(:url).returns("http://api.url")
    @transmission_api.stubs(:basic_auth).returns("user_pass")

    opts = { :key1 => "value1" }

    opts_expected = {
      :body => { :key1 => "value1" }.to_json,
      :headers => { "x-transmission-session-id" => "SESSION-ID" },
      :basic_auth => "user_pass"
    }

    response_mock =
      stub(
        :code => "",
        :message => "",
        :headers => "",
        :body => {}.to_json
      )

    HTTParty.expects(:post).with( "http://api.url", opts_expected ).returns( response_mock )

    @transmission_api.post(opts)
  end

  def test_post_with_409
    @transmission_api.stubs(:url).returns("http://api.url")
    @transmission_api.instance_variable_set(:@session_id, "SESSION-ID")

    opts = { :key1 => "value1" }

    opts_expected_1 = {
      :body => { :key1 => "value1" }.to_json,
      :headers => { "x-transmission-session-id" => "SESSION-ID" }
    }

    opts_expected_2 = {
      :body => { :key1 => "value1" }.to_json,
      :headers => { "x-transmission-session-id" => "NEW-SESSION-ID" }
    }

    response_mock_1 =
      stub(
        :code => 409,
        :message => "",
        :headers => { "x-transmission-session-id" => "NEW-SESSION-ID" },
        :body => ""
      )

    response_mock_2 =
      stub(
        :code => 200,
        :message => "",
        :headers => "",
        :body => {"key" => "value"}.to_json
      )

    post_sequence = sequence("post_sequence")
    HTTParty.expects(:post).with( "http://api.url", opts_expected_1 ).returns( response_mock_1 ).in_sequence( post_sequence )
    HTTParty.expects(:post).with( "http://api.url", opts_expected_2 ).returns( response_mock_2 ).in_sequence( post_sequence )

    assert_equal "value", @transmission_api.post(opts)["key"]
    assert_equal "NEW-SESSION-ID", @transmission_api.instance_variable_get(:@session_id)
  end

  def test_all
    opts_expected = {
      :method => "torrent-get",
      :arguments => { :fields => "fields" }
    }
    result = { "arguments" => { "torrents" => "torrents" } }

    @transmission_api.stubs(:fields).returns("fields")
    @transmission_api.expects(:post).with( opts_expected ).returns( result )

    assert_equal( "torrents", @transmission_api.all )
  end

  def test_find
    opts_expected = {
      :method => "torrent-get",
      :arguments => { :fields => "fields", :ids => [1] }
    }
    result = { "arguments" => { "torrents" => ["torrent1"] } }

    @transmission_api.stubs(:fields).returns("fields")
    @transmission_api.expects(:post).with( opts_expected ).returns( result )

    assert_equal( "torrent1", @transmission_api.find(1) )
  end

  def test_create
    opts_expected = {
      :method => "torrent-add",
      :arguments => { :filename => "filename" }
    }
    result = { "arguments" => { "torrent-added" => "torrent-added" } }

    @transmission_api.expects(:post).with( opts_expected ).returns( result )

    assert_equal( "torrent-added", @transmission_api.create( "filename" ) )
  end

  def test_destroy
    opts_expected = {
      :method => "torrent-remove",
      :arguments => { :ids => [1], :"delete-local-data" => true }
    }

    @transmission_api.expects(:post).with( opts_expected )
    @transmission_api.destroy(1)
  end

end