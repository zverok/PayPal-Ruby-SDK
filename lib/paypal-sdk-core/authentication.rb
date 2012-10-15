
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
      third_party_credential(url) || base_credential
    end
    
    def base_credential
      @credential ||=
        if config.cert_path
          Credential::Certificate.new(config)
        else
          Credential::Signature.new(config)
        end
    end
    
    def third_party_credential(url)
      @third_party_auth ||= 
        if config.token and config.token_secret
          Credential::ThirdParty::Token.new(base_credential, config, url)
        elsif config.subject
          Credential::ThirdParty::Subject.new(base_credential, config)
        end
    end
    
    def set_header_value(header_keys, properties)
      header = {}
      properties.each do |key, value|
        key = header_keys[key]
        header[key] = value if key
      end
      header      
    end
        
    # Configure ssl certificate to HTTP object
    # === Argument
    # * <tt>http</tt> -- Net::HTTP object         
    def add_certificate(http)
      if base_credential.is_a? Credential::Certificate
        http.cert = base_credential.cert
        http.key  = base_credential.key
      else
        http.cert = nil 
        http.key  = nil
      end
    end
  end
end