require 'paypal-sdk-core/http'

module PayPal::SDK::Core
  class API
    
    include PayPal::SDK::Core::Configuration
    include PayPal::SDK::Core::Logging
    
    HTTP_HEADER = {}
    
    attr_accessor :http, :uri
    
    def initialize(service_path = "/", environment = nil, options = {})
      unless service_path.is_a? String
        environment, options, service_path = service_path, environment || {}, "/"
      end   
      set_config(environment, options)
      create_http_connection(service_path)
    end
    
    def create_http_connection(service_path)
      service_path = "#{service_endpoint}/#{service_path}" unless service_path =~ /^https?:\/\//
      @uri  = URI.parse(service_path)
      @http = HTTP.new(@uri.host, @uri.port)
      @http.set_config(config)
      @uri.path = @uri.path.gsub(/\/+/, "/")      
    end
    
    def service_endpoint
      config.end_point 
    end
    
    def http_header
      HTTP_HEADER
    end
    
    def request(action, params = {}, initheader = {})
      path, content = format_request(action, params)
      response      = @http.post(path, content, http_header.merge(initheader))
      format_response(action, response)
    end

    def format_request(action, params)
      [ @uri.path, params ]
    end
    
    def format_response(action, response)
      response
    end    
  end
end