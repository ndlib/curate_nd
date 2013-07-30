require 'net/ldap'
class LdapService

  attr_reader :net_id

  class_attribute :ldap_options

  LDAP_TIME_OUT = 15

  def initialize(net_id)
    @net_id = String(net_id)
  end

  class UserNotFoundError < RuntimeError
    def initialize(error_message)
      super(error_message)
    end
  end

  def preferred_email
    ldap_query[:mail].first
  end

  def display_name
    ldap_query[:displayName].first
  end

  private
  def ldap_lookup
    results = connection.search(
                  :base => 'o="University of Notre Dame", st=Indiana, c=US',
                  :attributes => ['uid', 'mail', 'displayName'],
                  :filter     => Net::LDAP::Filter.eq('uid', net_id),
                  :return_result => true
    ) 

    if results.blank?
      return nil
    end
    results.first
  end

  def ldap_query
    Timeout.timeout(LDAP_TIME_OUT){
      if !(result = ldap_lookup).blank?
        return result
      else
        raise UserNotFoundError.new("User: #{net_id} is not found.")
      end
    }
  end

  def connection
    @connection ||= Net::LDAP.new(ldap_options)
  end
end

