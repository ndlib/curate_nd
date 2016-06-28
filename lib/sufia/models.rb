module Sufia
  extend ActiveSupport::Autoload

  module Models
  end

  autoload :Utils, 'sufia/models/utils'

  attr_writer :queue

  def self.queue
    @queue ||= config.queue.new('sufia')
  end

  def self.config(&block)
    @@config ||= ::Rails::Railtie::Configuration.new

    yield @@config if block

    return @@config
  end
end
