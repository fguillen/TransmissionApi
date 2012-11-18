require_relative "transmission_api/version"
require "httparty"
require "json"
require "recursive_open_struct"

class TransmissionApi
  TORRENT_FIELDS = [
    "id",
    "name",
    "totalSize",
    "addedDate",
    "isFinished",
    "rateDownload",
    "rateUpload",
    "percentDone",
    "files"
  ]

  def initialize(opts)
    @url = opts[:url]
    @torrent_fields = opts[:fields] || TORRENT_FIELDS
    @auth = { :username => opts[:username], :password => opts[:password] } if opts[:username]
    @session_id = "NOT-INITIALIZED"
  end

  def all
    puts "XXX: get_torrents"

    response =
      post(
        :method => "torrent-get",
        :arguments => {
          :fields => @torrent_fields
        }
      )

    RecursiveOpenStruct.new( response["arguments"], :recurse_over_arrays => true ).torrents
  end

  def find(id)
    puts "XXX: get_torrent: #{id}"

    response =
      post(
        :method => "torrent-get",
        :arguments => {
          :fields => @torrent_fields,
          :ids => [id]
        }
      )

    RecursiveOpenStruct.new( response["arguments"], :recurse_over_arrays => true ).torrents.first
  end

  def create(filename)
    puts "XXX: add_torrent: #{filename}"

    response =
      post(
        :method => "torrent-add",
        :arguments => {
          :filename => filename,
          :pause => true
        }
      )

    RecursiveOpenStruct.new( response["arguments"]["torrent-added"] )
  end

  def destroy(id)
    puts "XXX: remove_torrent: #{id}"

    response =
      post(
        :method => "torrent-remove",
        :arguments => {
          :ids => [id],
          :"delete-local-data" => true
        }
      )

    RecursiveOpenStruct.new( response["arguments"]["torrent-added"] )
  end

  def post(opts)
    post_options = {
      :body => opts.to_json,
      :headers => { "x-transmission-session-id" => @session_id }
    }
    post_options.merge!( :basic_auth => @basic_auth ) if @basic_auth


    puts "XXX: url: #{@url}"
    puts "XXX: post_options: #{post_options}"

    response =
      HTTParty.post(
        @url,
        post_options
      )

    puts "XXX: response.body: #{response.body}"
    puts "XXX: response.code: #{response.code}"
    puts "XXX: response.message: #{response.message}"
    puts "XXX: response.headers: #{response.headers.inspect}"

    # retry connection if session_id incorrect
    if( response.code == 409 )
      @session_id = response.headers["x-transmission-session-id"]
      response = post(opts)
    end

    response
  end
end
