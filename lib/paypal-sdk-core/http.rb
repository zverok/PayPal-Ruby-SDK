require 'net/http'

module PayPal::SDK::Core
  class HTTP < Net::HTTP
    
    include Logging
    include Configuration
        
    def request(req, *args)
      add_headers(req)
      super
    end
    
    def add_headers(req)
      req["X-PAYPAL-SECURITY-USERID"]     = config.username
      req["X-PAYPAL-SECURITY-PASSWORD"]   = config.password
      req["X-PAYPAL-APPLICATION-ID"]      = config.app_id
      req["X-PAYPAL-SECURITY-SIGNATURE"]  = config.signature if config.signature 
    end
    
  end
end