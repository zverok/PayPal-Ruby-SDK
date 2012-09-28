require 'net/http'

module PayPal::SDK::Core
  class HTTP < Net::HTTP
    
    include Logging
    include Configuration
    include Authentication
      
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
      add_certificate(self)
    end
        
    def request(req, *args)
      add_headers(req)
      super
    end
    
  end
end