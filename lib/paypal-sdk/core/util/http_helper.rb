require 'net/https'

module PayPal::SDK::Core
  module Util
    module HTTPHelper

      include Configuration
      include Logging
      include Authentication

      # Create HTTP connection based on given service name or configured end point
      def create_http_connection(uri)
        new_http(uri).tap do |http|
          if config.http_timeout
            http.open_timeout = config.http_timeout
            http.read_timeout = config.http_timeout
          end
          configure_ssl(http) if uri.scheme == "https"
        end
      end

      # New raw HTTP object
      def new_http(uri)
        if config.http_proxy
          proxy = URI.parse(config.http_proxy)
          Net::HTTP.new(uri.host, uri.port, proxy.host, proxy.port, proxy.user, proxy.password)
        else
          Net::HTTP.new(uri.host, uri.port)
        end
      end

      # Apply ssl configuration to http object
      def configure_ssl(http)
        http.tap do |https|
          https.use_ssl = true
          if config.ca_file
            https.verify_mode = OpenSSL::SSL::VERIFY_PEER
            https.ca_file     = config.ca_file
          end
          https.verify_mode = config.http_verify_mode if config.http_verify_mode
          add_certificate(https)
        end
      end

    end
  end
end
