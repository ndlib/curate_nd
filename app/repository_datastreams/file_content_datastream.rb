# frozen_string_literal: true

require 'down/net_http'

# FileContentStream handles Antivirus and File Characterization of content
class FileContentDatastream < ActiveFedora::Datastream
  include Hydra::Derivatives::ExtractMetadata
  include Sufia::FileContent::Versions

  def extract_metadata
    return unless has_content?

    # I want to run Clam first, let that possibly raise exceptions
    # Then run fits and return that
    file_content = determine_filesource
    _clam, fits = Hydra::FileCharacterization.characterize(file_content, filename_for_characterization.join(''), :clam,
                                                           :fits) do |config|
      config[:clam] = antivirus_runner
      config[:fits] = characterization_runner
    end
    fits
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

  def determine_filesource
    if controlGroup == 'R'
      download_file_dest = File.join(Figaro.env.curate_worker_tmpdir, File.basename(dsLocation))
      Down::NetHttp.download(dsLocation, headers: { 'X-Api-Key' => Figaro.env.bendo_api_key },
                                         destination: download_file_dest)
      File.open(download_file_dest)
    else
      content
    end
  end
end
