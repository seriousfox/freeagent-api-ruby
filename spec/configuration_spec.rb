require_relative 'spec_helper'

describe FreeAgent do

  describe 'configuration' do
    it 'should accept a block for configuration' do
      FreeAgent.configure do |config|
        config.client_id = 123
        config.client_secret = "thisisasecret"
      end
    end
  end
end
