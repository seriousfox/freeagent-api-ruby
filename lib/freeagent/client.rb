require 'oauth2'
require 'multi_json'

module FreeAgent
  class Client
    def initialize(options={})
      options = FreeAgent.options.merge(options)
      @client_id = options[:client_id]
      @client_secret = options[:client_secret]
      @client = OAuth2::Client.new(@client_id, @client_secret, Client.client_options)
    end

    def self.client_options
      {
        :site => Client.site,
        :authorize_url => Client.authorize_url,
        :token_url => Client.token_url,
        :connection_opts => Client.connection_opts
      }
    end

    def self.site
      sites[ FreeAgent.environment || :production ]
    end

    def self.sites
      { :sandbox => 'https://api.sandbox.freeagent.com/v2/', :production => 'https://api.freeagent.com/v2/' }
    end

    def self.authorize_url
      'approve_app'
    end

    def self.token_url
      'token_endpoint'
    end

    def self.connection_opts
      { :headers => { :user_agent => "freeagent-api-rb", :accept => "application/json", :content_type => "application/json" } }
    end
    
    def fetch_access_token(auth_code, options)
      if options[:redirect_uri]
        @access_token = @client.auth_code.get_token(auth_code, options)
      else
        raise FreeAgent::ClientError.new('Redirect uri not specified')
      end
    end

    def access_token
      @access_token
    end

    def access_token=(token)
      @access_token = OAuth2::AccessToken.new(@client, token)
    end

    def get(path, params={})
      response = request(:get, "#{Client.site}#{path}", :params => params)
      response2 = request(:get, "https://api.freeagent.com/v2/bank_transaction_explanations?page=2&per_page=100&bank_account=92599", :params => params)
      # 
      # response = MultiJson.load(response.body)
      # response2 = MultiJson.load(response2.body)
      # flat_array = [response,response2].map(&:to_a).flatten
      # # Hash[*flat_array]
      # puts flat_array
      puts response.parsed['bank_transaction_explanations'] << response2.parsed['bank_transaction_explanations']
      puts '--------------'
      response.parsed
    end

    def post(path, data={})
      request(:post, "#{Client.site}#{path}", :data => data).parsed
    end

    def put(path, data={})
      request(:put, "#{Client.site}#{path}", :data => data).parsed
    end

    def delete(path, data={})
      request(:delete, "#{Client.site}#{path}", :data => data).parsed
    end
    
  private

    def request(method, path, options = {})
      if @access_token
        options[:params].merge!(:per_page => 100)
        options[:body] = MultiJson.encode(options[:data]) unless options[:data].nil?
        @access_token.send(method, path, options)
      else
        raise FreeAgent::ClientError.new('Access Token not set')
      end
      
    rescue OAuth2::Error => error
      api_error = FreeAgent::ApiError.new(error.response)
      puts api_error if FreeAgent.debug
      raise api_error
    end
    
    
    # {"server"=>"nginx/1.0.14", "date"=>"Mon, 24 Sep 2012 14:08:08 GMT", "content-type"=>"application/json; charset=utf-8", "transfer-encoding"=>"chunked", "connection"=>"close", "status"=>"200 OK", "link"=>"<https://api.freeagent.com/v2/bank_transaction_explanations?page=2&per_page=25&bank_account=92599>; rel='next', <https://api.freeagent.com/v2/bank_transaction_explanations?page=31&per_page=25&bank_account=92599>; rel='last'", "etag"=>"\"32b0959ea1a5327ac34fcce26d2d651b\"", "last-modified"=>"Thu, 19 Jan 2012 14:32:09 GMT", "cache-control"=>"max-age=0, private, must-revalidate", "x-ua-compatible"=>"IE=Edge,chrome=1", "x-runtime"=>"0.616217", "x-rev"=>"c265581", "x-host"=>"web4"}

    def links(response)
      links = ( response.headers["link"] || "" ).split(', ').map do |link|
        url, type = link.match(/<(.*?)>; rel='(\w+)'/).captures
        [type,url]
      end
      Hash[ *links.flatten ]
    end
    
  end
end
