require 'paypal-sdk-core/api'
require 'json'

module PayPal::SDK::Core
  class NVP < API
    
    NVP_HTTP_HEADER = {
      "X-PAYPAL-REQUEST-DATA-FORMAT"  => "JSON",
      "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON" 
    }
    
    def http_header
      super.merge(NVP_HTTP_HEADER)
    end
    
    def service_endpoint
      config.nvp_end_point || super
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
