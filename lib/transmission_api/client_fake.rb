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
      "hashString" => "77831ec368308f1031434c5581a76fd0c3e06cfd",
      "name" => "No Media Kings - Ghosts With Shit Jobs trailer",
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