module Doi
  class Datacite
    def self.mint(target)
      doi_request_object = DataciteMapper.call(target)
      Ezid::Identifier.mint(doi_request_object).id
    end

    def self.normalize_identifier(value)
      value.to_s.strip.
        gsub(" ", '').
        sub(/\A.*10\./, "doi:10.")
    end

    def self.remote_uri_for(identifier)
      begin
       URI.parse(File.join(resolver_url, identifier))
      rescue URI::InvalidURIError => e
        Raven.capture_exception(e)
        nil
      end
    end

    private

    def self.resolver_url
      ENV.fetch('DOI_RESOLVER')
    end
  end
end
