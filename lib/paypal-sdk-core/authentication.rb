require 'paypal-sdk-core/config'

module PayPal::SDK::Core
  module Authentication
    
    def self.included(klass)
      klass.class_eval do
        include Configuration
      end
    end
    
    def add_headers(request = {})
      request["X-PAYPAL-SECURITY-USERID"]     = config.username
      request["X-PAYPAL-SECURITY-PASSWORD"]   = config.password
      request["X-PAYPAL-APPLICATION-ID"]      = config.app_id
      request["X-PAYPAL-SECURITY-SIGNATURE"]  = config.signature  if config.signature
      request
    end
    
    def add_certificate(http = self)
      if config.cert_path and http
        cert_content = File.read(config.cert_path)
        http.cert = OpenSSL::X509::Certificate.new(cert_content)
        http.key  = OpenSSL::PKey::RSA.new(cert_content)
      end
    end
  end
end