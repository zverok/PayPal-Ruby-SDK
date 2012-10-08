require 'paypal-sdk-core/config'

module PayPal::SDK::Core
  
  # Contains methods to format credentials for HTTP protocol.
  # == Example
  #  include Authentication
  #  add_header(request)
  #  add_certificate(http)
  module Authentication
    
    # Load configuration when 
    def self.included(klass)
      klass.class_eval do
        include Configuration
      end
    end
    
    # Get or Set HTTP authentication Header.
    # === Arguments 
    # * <tt>request</tt> -- HTTP Request object or new Hash.
    def http_auth_header(request = {})
      request["X-PAYPAL-SECURITY-USERID"]     = config.username
      request["X-PAYPAL-SECURITY-PASSWORD"]   = config.password
      request["X-PAYPAL-APPLICATION-ID"]      = config.app_id
      request["X-PAYPAL-SECURITY-SIGNATURE"]  = config.signature  if config.signature
      request
    end
    
    # Get or Set SOAP authentication Header.
    # === Arguments 
    # * <tt>request</tt> -- request SOAP Hash or new Hash .
    def soap_auth_header(request = {})
      request["urn:RequesterCredentials"] = {
          "ebl:Credentials" => {
            "ebl:Username"  => config.username,
            "ebl:Password"  => config.password,
            "ebl:Signature" => config.signature         
      } }
      request
    end    
    
    # Configure ssl certificate to HTTP object
    # === Argument
    # * <tt>http</tt> -- Net::HTTP object         
    def add_certificate(http = self)
      if config.cert_path and http
        cert_content = File.read(config.cert_path)
        http.cert = OpenSSL::X509::Certificate.new(cert_content)
        http.key  = OpenSSL::PKey::RSA.new(cert_content)
      else
        http.cert = nil 
        http.key  = nil
      end
    end
  end
end