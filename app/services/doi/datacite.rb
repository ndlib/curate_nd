# frozen_string_literal: true

require('rest-client')
require('base64')
require('json')

module Doi
  class Datacite
    def self.mint(target)
      doi_request_object = DataciteMapper.call(target)
      create_doi(doi_request_object).id
    end

    def self.normalize_identifier(value)
      value.to_s.strip
           .gsub(' ', '')
           .sub(/\A.*10\./, 'doi:10.')
    end

    def self.remote_uri_for(identifier)
      URI.parse(File.join(resolver_url, identifier))
    rescue URI::InvalidURIError => e
      Raven.capture_exception(e)
      nil
    end

    # Concatenate user:password for basic authentication
    def self.auth_details
      "#{ENV.fetch('DOI_USERNAME')}:#{ENV.fetch('DOI_PASSWORD')}"
    end

    def self.resolver_url
      ENV.fetch('DOI_RESOLVER')
    end

    # send doi minting request to datacite
    def self.create_doi(doi_request)
      response = RestClient::Request.execute(
        method: :post,
        url: "https://#{ENV.fetch('DOI_HOST')}/dois/",
        headers: { 'Authorization' => "Basic #{Base64.encode64(auth_details)}",
                   'Content-Type' => 'application/vnd.api+json' },
        payload: JSON.parse(doi_request)
      )
      response.body
    rescue RestClient::Exception => e
      Raven.capture_exception(e)
      nil
    end
  end
end
