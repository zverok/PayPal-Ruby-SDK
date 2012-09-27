require 'net/http'

module PayPal::SDK::Core
  class HTTP < Net::HTTP
    
    include Logging
    include Configuration
      
    class << self
      def new(host = nil, *args)
        super
      end
    end
    
    def initialize(host = nil, *args)
      if host.is_a? String
        super
      else
        self.set_config(host, *args) if host
        uri = URI.parse(config.end_point)
        super(uri.host, uri.port)
      end
      configure_http_connection
    end
    
    def configure_http_connection
      self.use_ssl      = true
      self.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      if config.http_timeout
        self.open_timeout = config.http_timeout
        self.read_timeout = config.http_timeout
      end
      if config.cert_path
        if Dir.exists? config.cert_path
          self.ca_path = config.cert_path
        else
          self.ca_file = config.cert_path
        end 
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