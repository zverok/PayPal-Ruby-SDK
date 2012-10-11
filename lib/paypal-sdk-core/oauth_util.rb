require 'uri'
require 'cgi'
require 'openssl'
require 'base64'

module PayPal::SDK::Core
  class OauthUtil
    attr_accessor :config, :url, :timestamp
    
    def initialize(config, url, timestamp = nil)
      @config = config
      @url = url
      @timestamp = timestamp || Time.now.to_i.to_s
    end
    
    def authorization_string
      signature = oauth_signature
      "token=#{config.token},signature=#{signature},timestamp=#{timestamp}"
    end

    def oauth_signature
      key = [
        paypal_encode(config.password),
        paypal_encode(config.token_secret),
      ].join("&")
      
      digest = OpenSSL::HMAC.digest('sha1', key, base_string)
      Base64.encode64(digest).chomp
    end

    def base_string
      params = {
        "oauth_consumer_key" => config.username,
        "oauth_version" => "1.0",
        "oauth_signature_method" => "HMAC-SHA1",
        "oauth_token" => config.token,
        "oauth_timestamp" => timestamp,
      }
      sorted_query_string = params.sort.map{|v| v.join("=") }.join("&")

      base = [
        "POST",
        paypal_encode(url),
        paypal_encode(sorted_query_string)
      ].join("&")
      base = base.gsub(/%[0-9A-F][0-9A-F]/, &:downcase )
    end
    
    # The PayPalURLEncoder java class percent encodes everything other than 'a-zA-Z0-9 _'.
    # Then it converts ' ' to '+'.
    # Ruby's CGI.encode takes care of the ' ' and '*' to satisfy PayPal
    # (but beware, URI.encode percent encodes spaces, and does nothing with '*').
    # Finally, CGI.encode does not encode '.-', which we need to do here.
    def paypal_encode str
      CGI.escape(str).gsub('.', '%2E').gsub('-', '%2D')
    end
  end
end  

