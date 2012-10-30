
module PayPal::SDK::Core

  # Contains methods to format credentials for HTTP protocol.
  # == Example
  #  include Authentication
  #  credential(url)
  #  base_credential
  #  third_party_credential(url)
  #
  #  add_certificate(http)
  module Authentication

    include Configuration

    # Get credential object
    # === Argument
    # * <tt>url</tt> -- API request url
    def credential(url)
      third_party_credential(url) || base_credential
    end

    # Get base credential
    def base_credential
      @base_credential ||=
        if config.cert_path
          Credential::Certificate.new(config)
        else
          Credential::Signature.new(config)
        end
    end

    # Get third party credential
    def third_party_credential(url)
      if config.token and config.token_secret
        Credential::ThirdParty::Token.new(base_credential, config, url)
      elsif config.subject
        Credential::ThirdParty::Subject.new(base_credential, config)
      end
    end

    # Clear cached variables on changing the configuration.
    def set_config(*args)
      super
      @base_credential = nil
    end

    # Generate header based on given header keys and properties
    # === Arguments
    # * <tt>header_keys</tt> -- List of Header keys for the properties
    # * <tt>properties</tt>  -- properties
    # === Return
    #  Hash with header as key property as value
    # === Example
    # map_header_value( { :username => "X-PAYPAL-USERNAME"}, { :username => "guest" })
    # # Return: { "X-PAYPAL-USERNAME" => "guest" }
    def map_header_value(header_keys, properties)
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
