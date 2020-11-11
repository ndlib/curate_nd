# This is deprecated for actual VRA Core availability. None of these fields were in use so deprecating is ok. Not only was there a manual check, there was some unpleasant grepping.
# source in Image work was mapped to existing dc:source
module RDF
  class Image < Vocabulary("http://nd.edu/image#")
#    property :category
#    property :location
#    property :measurements
#    property :material
#    property :source
#    property :inscription
#    property :StateEdition
#    property :TEXTREF
#    property :cultural_context
#    property :style_period
#    property :technique
  end
end
