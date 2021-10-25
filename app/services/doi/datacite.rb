# frozen_string_literal: true

require('rest-client')
require('base64')
require('json')

module Doi
  class Datacite
    def self.mint(target)
      doi_request_object = DataciteMapper.call(target)
      create_doi(doi_request_object)
    end

    def self.normalize_identifier(value)
      value.to_s.strip
           .gsub(' ', '')
           .sub(/\A.*10\./, 'doi:10.')
    end

    def self.remote_uri_for(identifier)
      URI.parse(File.join(resolver_url, identifier))
    rescue URI::InvalidURIError => e
      Sentry.capture_exception(e)
      nil
    end

private

    # Concatenate user:password for basic authentication
    def self.auth_details
      "#{Figaro.env.doi_username}:#{Figaro.env.doi_password}"
    end

    def self.resolver_url
      Figaro.env.doi_resolver
    end

    # send doi minting request to datacite
    def self.create_doi(doi_request)
      response = RestClient::Request.execute(
        method: :post,
        url: "https://#{Figaro.env.doi_host}/dois/",
        headers: { 'Authorization' => "Basic #{Base64.encode64(auth_details)}",
                   'Content-Type' => 'application/vnd.api+json' },
        payload: doi_request
      )
    return 'doi:' + JSON.parse(response.body)['data']['id']
    rescue RestClient::Exception => e
      Sentry.capture_exception(e)
      nil
    end
  end
end
