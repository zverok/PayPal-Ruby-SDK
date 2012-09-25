require 'net/http'

module PayPal::SDK::Core
  class HTTP < Net::HTTP
    
    include Logging
    include Configuration
      
    def initialize(host = nil, *args)
      if [ Symbol, Hash, NilClass ].include? host.class
        self.config= host unless host.nil?
        uri = URI.parse(config.end_point)
        super(uri.host, uri.port)
        configure_http_connection
      else
        super
      end
    end
    
    def configure_http_connection
      self.use_ssl      = true
      self.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      if config.http_timeout
        self.open_timeout = config.http_timeout
        self.read_timeout = config.http_timeout
      end
    end
        
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