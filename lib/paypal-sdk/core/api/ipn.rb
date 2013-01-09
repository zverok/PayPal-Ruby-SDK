require 'net/https'

module PayPal
  module SDK
    module Core
      module API
        module IPN

          END_POINTS = {
            :sandbox => "https://www.sandbox.paypal.com/cgi-bin/webscr",
            :live    => "https://ipnpb.paypal.com/cgi-bin/webscr"
          }
          VERIFIED   = "VERIFIED"
          INVALID    = "INVALID"

          class Message
            include PayPal::SDK::Core::Configuration

            attr_accessor :message

            def initialize(message, env = nil, options = {})
              @message = message
              set_config(env, options)
            end

            # Fetch end point
            def ipn_end_point
              config.ipn_end_point || default_ipn_end_point
            end

            # Default IPN end point
            def default_ipn_end_point
              end_point = END_POINTS[(config.mode || :sandbox).to_sym] rescue nil
              end_point || END_POINTS[:sandbox]
            end

            # Request IPN service for validating the content
            # === Return
            # return http response object
            def request
              uri  = URI(ipn_end_point)
              http = Net::HTTP.new(uri.host, uri.port)
              if uri.scheme == "https"
                http.use_ssl = true
                if config.ca_file
                  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
                  http.ca_file =  config.ca_file
                end
              end
              query_string = "cmd=_notify-validate&#{message}"
              http.post(uri.path, query_string)
            end

            # Validate the given content
            # === Return
            # return true or false
            def valid?
              request.body == VERIFIED
            end
          end

          class << self
            def valid?(*args)
              Message.new(*args).valid?
            end

            def request(*args)
              Message.new(*args).request
            end
          end

        end
      end
    end
  end
end
