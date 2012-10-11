require 'paypal-sdk-core/config'
require 'paypal-sdk-core/oauth_util'

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
    
    # Get HTTP authentication Header.
    # === Arguments 
    # * <tt>request</tt> -- HTTP Request object or new Hash.
    def http_auth_header(url)
      header = {}
      if has_oauth_token?
        header["X-PAYPAL-AUTHORIZATION"]       = oauth_signature(url)
      else
        header["X-PAYPAL-SECURITY-USERID"]     = config.username
        header["X-PAYPAL-SECURITY-PASSWORD"]   = config.password
        header["X-PAYPAL-SECURITY-SIGNATURE"]  = config.signature  if config.signature
      end
      header["X-PAYPAL-APPLICATION-ID"]       = config.app_id
      header
    end

    # Check the oauth token is configured or not.
    def has_oauth_token?
      config.token and config.token_secret
    end
    
    # Generate Oauth Signature.
    def oauth_signature(url)
      oauth = OauthUtil.new(config, url)
      oauth.authorization_string
    end
    
    # Get or Set SOAP authentication Header.
    # === Arguments 
    # * <tt>request</tt> -- request SOAP Hash or new Hash .
    def soap_auth_header
      header = { "urn:RequesterCredentials" => {} }
      header["urn:RequesterCredentials"]["ebl:Credentials"] = {
        "ebl:Username"  => config.username,
        "ebl:Password"  => config.password,
        "ebl:Signature" => config.signature         
      } unless has_oauth_token? 
      header
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