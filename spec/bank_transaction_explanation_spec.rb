require_relative 'spec_helper'

describe FreeAgent::BankTransactionExplanation do
  before :each do
    FreeAgent.configure do |c|
      c.client_id = 123
      c.client_secret = 'secret'
    end
    
    @explanations = FreeAgent::BankTransactionExplanation
  end 

  describe '#find_all_by_bank_account' do
    context 'with a bank account id' do
    end

    context 'with a options' do
    end
  end
end
