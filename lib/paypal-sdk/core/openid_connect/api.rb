require 'multi_json'

module PayPal::SDK
  module Core
    module OpenIDConnect
      class API < Core::API::Base

        DEFAULT_OPENID_ENDPOINT ="https://api.paypal.com"

        def initialize(environment = nil, options = {})
          super("", environment, options)
        end

        def service_endpoint
          self.config.openid_endpoint || DEFAULT_OPENID_ENDPOINT
        end

        def format_request(payload)
          payload[:uri].path = url_join(payload[:uri].path, payload[:action])
          payload[:body]    = encode_www_form(payload[:params]) if payload[:params]
          payload[:header]  = {"Content-Type" => "application/x-www-form-urlencoded" }.merge(payload[:header])
          payload
        end

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

      end
    end
  end
end
