module Api
  # an object to assist with testing to avoid using S3
  class MemoryBucket
    def initialize
      @memory = {}
    end

    def object(path)
      @memory[path] ||= MemoryObject.new
      @memory.fetch(path)
    end

    class MemoryObject
      def put(body:)
        @body = body
      end
      attr_reader :body
    end
  end
end
