# frozen_string_literal: true

require 'down/net_http'
require 'http'

# FileContentStream handles Antivirus and File Characterization of content
class FileContentDatastream < ActiveFedora::Datastream
  include Hydra::Derivatives::ExtractMetadata
  include Sufia::FileContent::Versions

  def extract_metadata
    return unless has_content?

    
    # if the content is in bendo, file_content will be an open file descriptor to the downloaded file,
    # if not, it will be the ActiveFedora object's content datastream
    file_content = return_file_content

    # Run Clam first, let that possibly raise exceptions
    # Then run fits and return that
    _clam, fits = Hydra::FileCharacterization.characterize(file_content, filename_for_characterization.join(''), :clam,
                                                           :fits) do |config|
      config[:clam] = antivirus_runner
      config[:fits] = characterization_runner
    end
    # If we downloaded it ourselves, delete the tempfile
    if file_content.is_a?(File)
      File.delete(file_content.path)
    end
    fits
  end

  def return_file_content
    return unless has_content?

    # For bendo datastreams, download the file directly rather than use the Activerfedora content,
    # lest for big files we run out of memory.
    if controlGroup == 'R'  # file is in bendo
      download_from_bendo
    else # file is in content datastream
      content
    end
  end

  protected

  def antivirus_runner
    AntiVirusScanner.new(self)
  end

  def characterization_runner
    if Curate.configuration.characterization_runner.respond_to?(:call)
      Curate.configuration.characterization_runner
    else
      Sufia.config.fits_path
    end
  end

  def download_from_bendo
    # Create full download path of file
    download_file_dest = File.join(Figaro.env.curate_worker_tmpdir, File.basename(dsLocation))

    begin
      download_from_dsLocation(download_file_dest)
    rescue Down::ServerError
      sleep(10)
      retry if check_bendo_caching == '0'
    end

    #Return open file descriptor so Hydra::FileCharacterization knows not to use the content DS
    File.open(download_file_dest)
  end

  def download_from_dsLocation(file_dest)
    # Set TMPDIR in environment so that open_uri creates its tempfiles in the download area
    # rather than the system /tmp
    ENV['TMPDIR'] = Figaro.env.curate_worker_tmpdir + '/tmp'

    # try download from bendo API using dsLocation uri in the datastream
    Down::NetHttp.download(dsLocation, headers: { 'X-Api-Key' => Figaro.env.bendo_api_key },
                                       destination: file_dest,
                                       open_timeout: 300,
                                       read_timeout: 3600)

  end

  def check_bendo_caching
    response = HTTP.head(dsLocation, headers: { 'X-Api-Key' => Figaro.env.bendo_api_key })
    response.headers['X-Cached']
  end
end
