require 'rsolr/client'

module RSolr
  class Client
    # I've been working to use a module and super method, but that is not working.
    # So instead I'm leveraging the alternate as defined by Jay Field's blog http://blog.jayfields.com/2006/12/ruby-alias-method-alternative.html
    add_instance_method = instance_method(:add)
    define_method(:add) do |doc, *args|
      sanitized_document = SanitizeControlCharactersForIndexing.sanitize_document(doc)
      add_instance_method.bind(self).call(sanitized_document, *args)
    end

    # Responsible for exposing a sanitization method for control characters when indexing Solr.
    #
    # Without these changes we end up with an exception of the following form:
    #
    # ```ruby
    #   RSolr::Error::Http - 400 Bad Request
    #   Error: {'responseHeader'=>{'status'=>400,'QTime'=>31},'error'=>{'msg'=>'Illegal character ((CTRL-CHAR, code 12))
    #     at [row,col {unknown-source}]: [1,70]','code'=>400}}
    # ```
    module SanitizeControlCharactersForIndexing
      def self.sanitize_document(doc)
        sanitized_doc = {}
        doc.each_pair do |key, value|
          sanitized_doc[key] = sanitize_value(value)
        end
        sanitized_doc
      end
      def self.sanitize_value(value)
        case value
        when Hash
          sanitize_document(value)
        when Array
          value.map { |v| sanitize_value(v) }
        when String
          value.gsub(/[[:cntrl:]]/) do |character|
            case character
            when "\t", "\n", "\r"
              character
            else
              " "
            end
          end
        else
          value
        end
      end
    end
  end
end
