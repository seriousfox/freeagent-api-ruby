module FreeAgent
  class BankTransactionExplanation < Resource
    resource :bank_transaction_explanation

    resource_methods :find, :filter 

    attr_accessor :url, :bank_transaction, :bank_account, :category, :description
   
    decimal_accessor :gross_value

    date_accessor :dated_on

    #TODO Add Attachment accessors

    def self.find_all_by_bank_account(bank_account, options = {})
      options.merge!(:bank_account => "https://api.freeagent.com/v2/bank_accounts/#{bank_account}")
      BankTransactionExplanation.filter(options) 
    end
  end
end
