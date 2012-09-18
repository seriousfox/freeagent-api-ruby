module FreeAgent
  require_relative 'freeagent/client'
  require_relative 'freeagent/errors'  

  require_relative 'freeagent/resource'
  require_relative 'freeagent/user'
  require_relative 'freeagent/company'
  require_relative 'freeagent/timeline_item'
  require_relative 'freeagent/attachment'

  require_relative 'freeagent/contact'
  require_relative 'freeagent/project'
  require_relative 'freeagent/task'
  require_relative 'freeagent/timeslip'
  require_relative 'freeagent/note'
  require_relative 'freeagent/recurring_invoice'
  require_relative 'freeagent/invoice'
  require_relative 'freeagent/bank_account'
  require_relative 'freeagent/estimate'
  require_relative 'freeagent/expense'

  class << self
    VALID_KEYS = [:client_id, :client_secret, :access_token]
    attr_accessor *VALID_KEYS
    attr_accessor :environment
    attr_accessor :debug
    attr_reader :client
    
    def options
      Hash[ * VALID_KEYS.map { |key| [key, send(key)] }.flatten ]
    end

    def configure
     yield self
     @client = Client.new
     @client.access_token = self.access_token
     @client
    end
  end
end
