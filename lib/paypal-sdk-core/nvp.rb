require 'paypal-sdk-core/api'
require 'json'

module PayPal::SDK::Core
  
  # Use NVP protocol to communicate with the Web services
  # == Example
  #   api       = NVP.new("AdaptivePayments")
  #   response  = client.request("ConvertCurrency", {
  #     "baseAmountList"        => { "currency" => [ { "code" => "USD", "amount" => "2.0"} ]},
  #     "convertToCurrencyList" => { "currencyCode" => ["GBP"] } })
  class NVP < API
    
    NVP_HTTP_HEADER = {
      "X-PAYPAL-REQUEST-DATA-FORMAT"  => "JSON",
      "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON" 
    }
    DEFAULT_PARAMS = {
      "requestEnvelope"       => { "errorLanguage" => "en_US" }
    } 
    
    # Get NVP HTTP header
    def http_header
      super.merge(NVP_HTTP_HEADER)
    end
    
    # Get NVP service end point
    def service_endpoint
      config.nvp_end_point || super
    end
    
    # Format the Request.
    # === Arguments
    # * <tt>action</tt> -- Action to perform
    # * <tt>params</tt> -- Action parameters will be in Hash
    # === Return
    # * <tt>request_path</tt> -- Generated URL for requested action
    # * <tt>request_content</tt> -- Format parameters in JSON with default values.          
    def format_request(action, params)
      request_path = (@uri.path + "/" + action).gsub(/\/+/, "/")
      [ request_path, DEFAULT_PARAMS.merge(params).to_json ]
    end
    
    # Format the Response object
    # === Arguments
    # * <tt>action</tt> -- Requested action name
    # * <tt>response</tt> -- HTTP response object
    # === Return
    # Parse response content using JSON and return the Hash object
    def format_response(action, response)
      if response.code == "200"
        JSON.parse(response.body)
      else
        format_error(response, response.message)
      end
    end
    
    # Format Error object.
    # == Arguments
    # * <tt>exception</tt> -- Exception object or HTTP response object.
    # * <tt>message</tt> -- Readable error message.
    def format_error(exception, message)
      {"responseEnvelope" => {"ack" => "Failure"}, "error" => [{"message" => message, "exception" => exception}]}
    end
  end
end
