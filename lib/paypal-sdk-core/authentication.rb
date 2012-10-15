
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
    
    def credential(url)
      third_party_auth(url) || i_credential
    end
    
    def i_credential
      @credential ||=
        if config.cert_path
          Credential::Certificate.new(config)
        else
          Credential::Signature.new(config)
        end
    end
    
    def third_party_auth(url)
      @third_party_auth ||= 
        if config.token and config.token_secret
          Credential::ThirdParty::Token.new(i_credential, config, url)
        elsif config.subject
          Credential::ThirdParty::Subject.new(i_credential, config)
        end
    end
    
    HTTP_AUTH_HEADER = {
      :username       => "X-PAYPAL-SECURITY-USERID",
      :password       => "X-PAYPAL-SECURITY-PASSWORD",
      :signature      => "X-PAYPAL-SECURITY-SIGNATURE",
      :app_id         => "X-PAYPAL-APPLICATION-ID",
      :authorization  => "X-PAYPAL-AUTHORIZATION"
    }
    
    SOAP_AUTH_HEADER = {
      :username   => "ebl:Username",
      :password   => "ebl:Password",
      :signature  => "ebl:Signature",
      :subject    => "ebl:Subject"
    }
    
    # Get HTTP authentication Header.
    # === Arguments 
    # * <tt>url</tt> -- Request url.
    def http_auth_header(url)
      header = {}
      credential(url).properties.each do |key, value|
        key = HTTP_AUTH_HEADER[key]
        header[key] = value if key
      end
      header
    end

    # Check the oauth token is configured or not.
    def has_oauth_token?
      config.token and config.token_secret
    end
    
    # Get or Set SOAP authentication Header.
    # === Arguments 
    # * <tt>url</tt> -- Request url.
    def soap_auth_header(url)
      header = { "urn:RequesterCredentials" => {} }
      user_auth = {}
      credential(url).properties.each do |key, value|
        key = SOAP_AUTH_HEADER[key]
        user_auth[key] = value if key
      end
      header["urn:RequesterCredentials"]["ebl:Credentials"] = user_auth 
      header
    end    
    
    # Configure ssl certificate to HTTP object
    # === Argument
    # * <tt>http</tt> -- Net::HTTP object         
    def add_certificate(http)
      if i_credential.is_a? Credential::Certificate
        http.cert = i_credential.cert
        http.key  = i_credential.key
      else
        http.cert = nil 
        http.key  = nil
      end
    end
  end
end