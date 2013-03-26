require 'multi_json'

module PayPal::SDK::Core
  module API
    class REST < Base
      NVP_AUTH_HEADER = {
        :sandbox_email_address => "X-PAYPAL-SANDBOX-EMAIL-ADDRESS",
        :device_ipaddress      => "X-PAYPAL-DEVICE-IPADDRESS"
      }
      DEFAULT_HTTP_HEADER = {
        "Content-Type" => "application/json"
      }

      DEFAULT_REST_END_POINTS = {
        :sandbox => "https://api.sandbox.paypal.com",
        :live    => "https://api.paypal.com"
      }
      TOKEN_REQUEST_PARAMS = "grant_type=client_credentials"

      # Get REST service end point
      def service_endpoint
        config.rest_endpoint || super || DEFAULT_REST_END_POINTS[api_mode]
      end

      # Token endpoint
      def token_endpoint
        config.rest_token_endpoint || service_endpoint
      end

      # Clear cached values.
      def set_config(*args)
        @token_uri = nil
        @token = nil
        super
      end

      # URI object token endpoint
      def token_uri
        @token_uri ||=
          begin
            new_uri = URI.parse(token_endpoint)
            new_uri.path = "/v1/oauth2/token" if new_uri.path =~ /^\/?$/
            new_uri
          end
      end

      # Generate Oauth token or Get cached
      def token
        @token ||=
          begin
            basic_auth = ["#{config.client_id}:#{config.client_secret}"].pack('m').delete("\r\n")
            token_headers = default_http_header.merge( "Authorization" => "Basic #{basic_auth}" )
            response = http_call( :method => :post, :uri => token_uri, :body => TOKEN_REQUEST_PARAMS, :header => token_headers )
            MultiJson.load(response.body)["access_token"]
          end
      end

      # token setter
      def token=(new_token)
        @token = new_token
      end

      # Override the API call to handle Token Expire
      def api_call(payload)
        backup_payload  = payload.dup
        begin
          response = super(payload)
        rescue UnauthorizedAccess => error
          if @token and config.client_id
            # Reset cached token and Retry api request
            @token = nil
            response = super(backup_payload)
          else
            raise error
          end
        end
        response
      end

      # Validate HTTP response
      def handle_response(response)
        super
      rescue BadRequest => error
        # Catch BadRequest to get validation error message from the response.
        error.response
      end

      # Format request payload
      # === Argument
      # * payload( uri, action, params, header)
      # === Generate
      # * payload( uri, body, header )
      def format_request(payload)
        # Request URI
        payload[:uri].path = url_join(payload[:uri].path, payload[:action])
        # HTTP Header
        credential_properties = credential(payload[:uri].to_s).properties
        header = map_header_value(NVP_AUTH_HEADER, credential_properties)
        payload[:header]  = header.merge("Authorization" => "Bearer #{token}").
          merge(DEFAULT_HTTP_HEADER).merge(payload[:header])
        # Post Data
        payload[:body]    = MultiJson.dump(payload[:params])
        payload
      end

      # Format response payload
      # === Argument
      # * payload( response )
      # === Generate
      # * payload( data )
      def format_response(payload)
        payload[:data] =
          if payload[:response].code >= "200" and payload[:response].code <= "299"
            MultiJson.load(payload[:response].body)
          elsif payload[:response].content_type == "application/json"
            { "error" => MultiJson.load(payload[:response].body) }
          else
            { "error" => { "name" => payload[:response].code, "message" => payload[:response].message,
              "developer_msg" => payload[:response] } }
          end
        payload
      end

      # Log PayPal-Request-Id header
      def log_http_call(payload)
        if payload[:header] and payload[:header]["PayPal-Request-Id"]
          logger.info "PayPal-Request-Id: #{payload[:header]["PayPal-Request-Id"]}"
        end
        super
      end

    end
  end
end
