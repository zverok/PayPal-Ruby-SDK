require 'net/http'

module PayPal::SDK::Core
  
  # Wrapper class Net::HTTP class
  # == Example
  #   uri       = URI.parse("https://svcs.sandbox.paypal.com/")
  #   http      = HTTP.new(uri.host, uri.port)
  #   response  = http.post("/AdaptivePayments/GetPaymentOptions", "")
  class HTTP < Net::HTTP
    
    include Logging
    include Configuration
    include Authentication
    
    # Initialize HTTP object and configure HTTP connection based on environment
    def initialize(*args)
      super
      configure_http_connection
    end
    
    # Change default configuration and update the configuration for HTTP connection.
    def set_config(*args)
      super
      configure_http_connection
    end
    
    # Configure HTTP connection.
    def configure_http_connection
      self.use_ssl      = true
      self.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      if config.http_timeout
        self.open_timeout = config.http_timeout
        self.read_timeout = config.http_timeout
      end
      add_certificate(self)
    end
    
    # Add Authentication header for each request.    
    def request(req, *args)
      add_headers(req)
      super
    end
    
  end
end