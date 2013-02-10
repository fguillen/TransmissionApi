class TransmissionApi::ClientFake < TransmissionApi::Client

  attr_reader :torrents

  def initialize(opts)
    super
    torrents_path = opts[:torrents_path] || "#{File.dirname(__FILE__)}/../torrents_fake.json"
    @torrents = JSON.parse(File.read(torrents_path))
  end

  def all
    torrents
  end

  def find(id)
    torrents.select { |e| e["hashString"] == id }.first
  end

  def create(filename)
    torrent = {
      "files" => [],
      "hashString" => Digest::MD5.hexdigest(Time.now.to_i.to_s),
      "name" => "Wadus name torrent",
      "percentDone" => 0,
      "rateUpload" => 0,
      "rateDownload" => 0,
      "totalSize" => 100
    }

    torrents << torrent

    torrent
  end

  def destroy(id)
    torrents.delete_if { |e| e["hashString"] == id }
  end

end