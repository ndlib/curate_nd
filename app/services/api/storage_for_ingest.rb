require 'aws-sdk-s3'

module Api
  # compartmentalizes use of S3 bucket for api uploads
  class StorageForIngest
    attr_reader :bucket
    def initialize(bucket: default_bucket)
      @bucket = bucket
    end

    def put(named_path:, body:)
      named_object = bucket.object(named_path)
      named_object.put(body: body)
    end

    private
    def default_bucket
      if Rails.application.config.bucket_for_ingest
        Rails.application.config.bucket_for_ingest
      else
        Aws::S3::Resource.new(region: 'us-east-1').bucket(ENV['S3_BUCKET'])
      end
    end
  end
end
