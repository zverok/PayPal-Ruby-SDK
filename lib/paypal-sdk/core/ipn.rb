require 'net/http'

module PayPal
  module SDK
    module Core
      module IPN

        END_POINTS = {
          :sandbox => "https://ipnpb.sandbox.paypal.com/cgi-bin/webscr",
          :live    => "https://ipnpb.paypal.com/cgi-bin/webscr"
        }
        VERIFIED   = "VERIFIED"
        INVALID    = "INVALID"

        class << self
          include PayPal::SDK::Core::Configuration

          # Fetch end point
          def ipn_end_point
            end_point = END_POINTS[(config.mode || :sandbox).to_sym] rescue nil
            end_point || END_POINTS[:sandbox]
          end

          # Request IPN service for validating the content
          # === Arguments
          # * <tt>content<tt> Raw post content
          # === Return
          # return http response object
          def request(content)
            uri  = URI(ipn_end_point)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.ca_file =  config.ca_file if config.ca_file
            query_string = "cmd=_notify-validate&" + content
            http.post(uri.path, query_string)
          end

          # Verify the given content
          # === Arguments
          # * <tt>content<tt> Raw post content
          # === Return
          # return true or false
          def verify?(content)
            request(content).body == VERIFIED
          end
        end

      end
    end
  end
end
