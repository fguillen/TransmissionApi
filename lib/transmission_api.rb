require_relative "transmission_api/version"
require "httparty"
require "json"

class TransmissionApi
  attr_accessor :session_id
  attr_accessor :url
  attr_accessor :basic_auth
  attr_accessor :torrent_fields
  attr_accessor :debug_mode

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
    @basic_auth = { :username => opts[:username], :password => opts[:password] } if opts[:username]
    @session_id = "NOT-INITIALIZED"
    @debug_mode = opts[:debug_mode] || false
  end

  def all
    log "get_torrents"

    response =
      post(
        :method => "torrent-get",
        :arguments => {
          :fields => torrent_fields
        }
      )

    response["arguments"]["torrents"]
  end

  def find(id)
    log "get_torrent: #{id}"

    response =
      post(
        :method => "torrent-get",
        :arguments => {
          :fields => torrent_fields,
          :ids => [id]
        }
      )

    response["arguments"]["torrents"].first
  end

  def create(filename)
    log "add_torrent: #{filename}"

    response =
      post(
        :method => "torrent-add",
        :arguments => {
          :filename => filename
        }
      )

    response["arguments"]["torrent-added"]
  end

  def destroy(id)
    log "remove_torrent: #{id}"

    response =
      post(
        :method => "torrent-remove",
        :arguments => {
          :ids => [id],
          :"delete-local-data" => true
        }
      )

    response
  end

  def post(opts)
    JSON::parse( http_post(opts).body )
  end

  def http_post(opts)
    post_options = {
      :body => opts.to_json,
      :headers => { "x-transmission-session-id" => session_id }
    }
    post_options.merge!( :basic_auth => basic_auth ) if basic_auth

    log "url: #{url}"
    log "post_options: #{post_options}"

    response = HTTParty.post( url, post_options )

    log "response.body: #{response.body}"
    log "response.code: #{response.code}"
    log "response.message: #{response.message}"
    log "response.headers: #{response.headers.inspect}"

    # retry connection if session_id incorrect
    if( response.code == 409 )
      log "changing session_id"
      @session_id = response.headers["x-transmission-session-id"]
      response = http_post(opts)
    end

    response
  end

  def log(message)
    Kernel.puts "[TransmissionApi #{Time.now.strftime( "%F %T" )}] #{message}" if debug_mode
  end
end
