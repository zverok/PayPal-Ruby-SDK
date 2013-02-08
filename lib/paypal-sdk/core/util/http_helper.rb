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
          config.ssl_options.each do |key, value|
            http.send("#{key}=", value)
          end
          add_certificate(https)
        end
      end

      # Join url
      def url_join(path, action)
        path.sub(/\/?$/, "/#{action}")
      end

      # Make Http call
      # * payload - Hash(:http, :method, :uri, :body, :header)
      def http_call(payload)
        log_http_call(payload) do
          http = payload[:http] || create_http_connection(payload[:uri])
          http.start do |session|
            if payload[:method] == :get
              session.get(payload[:uri].request_uri, payload[:header])
            else
              session.send(payload[:method], payload[:uri].request_uri, payload[:body], payload[:header])
            end
          end
        end
      end

      # Log Http call
      # * payload - Hash(:http, :method, :uri, :body, :header)
      def log_http_call(payload)
        logger.info "Action: #{payload[:action]}" if payload[:action]
        logger.info "Request[#{payload[:method]}]: #{payload[:uri].to_s}"
        start_time = Time.now
        response = yield
        logger.info sprintf("Response[%s]: %s, Duration: %.3fs", response.code, response.message, Time.now - start_time)
        response
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
          header[key] = value if key and value
        end
        header
      end


    end
  end
end
