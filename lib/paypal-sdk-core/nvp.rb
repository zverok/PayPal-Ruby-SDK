require 'paypal-sdk-core/http'
require 'json'

module PayPal::SDK::Core
  class NVP
    
    include PayPal::SDK::Core::Configuration
    include PayPal::SDK::Core::Logging
    
    DefaultHeaders = {
      "X-PAYPAL-REQUEST-DATA-FORMAT"  => "JSON",
      "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON" 
    }

    attr_accessor :http, :uri
    
    def initialize(prefix = "/", environment = nil, options = {})
      unless prefix.is_a? String
        environment, options, prefix = prefix, environment || {}, "/"
      end
      set_config(environment, options)
      @uri  = URI.parse((config.nvp_end_point || config.end_point) + "/" + prefix)
      @http = HTTP.new(@uri.host, @uri.port)
      @http.set_config(config)
    end
        
    def request(action, params = {}, headers = {})
      url, content = format_request(action, params)
      response     = @http.post(url, content, headers.merge(DefaultHeaders))
      format_response(action, response)
    end
    
    def format_request(action, params)
      request_path = (@uri.path + "/" + action).gsub(/\/+/, "/")
      [ request_path, params.to_json ]
    end
    
    def format_response(action, response)
      JSON.parse(response.body)
    end
  end
end
