require 'net/http'

module PayPal::SDK::Core
  
  module API
    # API class provide default functionality for accessing the API web services.
    # == Example
    #   api      = API::Base.new("AdaptivePayments")
    #   response = api.request("GetPaymentOptions", "")
    class Base
      
      include Configuration
      include Logging
      include Authentication
  
      DEFAULT_HTTP_HEADER = {}
      
      attr_accessor :http, :uri, :service_name
      
      # Initialize API object
      # === Argument
      # * <tt>service_name</tt> -- (Optional) Service name
      # * <tt>environment</tt>  -- (Optional) Configuration environment to load
      # * <tt>options</tt> -- (Optional) Override configuration.
      # === Example
      #  new("AdaptivePayments")
      #  new("AdaptivePayments", :development)
      #  new(:wsdl_service)       # It load wsdl_service configuration 
      def initialize(service_name = "", environment = nil, options = {})
        unless service_name.is_a? String
          environment, options, service_name = service_name, environment || {}, ""
        end   
        @service_name = service_name
        set_config(environment, options)
      end
      
      # Override set_config method to create http connection on changing the configuration.
      def set_config(*args)
        super
        create_http_connection      
      end
      
      # Create HTTP connection based on given service name or configured end point
      def create_http_connection
        service_path = "#{service_endpoint}/#{service_name}"
        @uri  = URI.parse(service_path)
        @http = Net::HTTP.new(@uri.host, @uri.port)
        @uri.path = @uri.path.gsub(/\/+/, "/")
        configure_http_connection      
      end
      
      # Configure HTTP connection based on configuration.
      def configure_http_connection
        http.use_ssl      = true
        http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
        if config.http_timeout
          http.open_timeout = config.http_timeout
          http.read_timeout = config.http_timeout
        end
        add_certificate(http)
      end
      
      # Get service end point
      def service_endpoint
        config.end_point 
      end
      
      # Get default HTTP header
      def http_header
        DEFAULT_HTTP_HEADER
      end
      
      # Generate HTTP request for given action and parameters
      # === Arguments
      # * <tt>action</tt> -- Action to perform
      # * <tt>params</tt> -- (Optional) Parameters for the action
      # * <tt>initheader</tt> -- (Optional) HTTP header
      def request(action, params = {}, initheader = {})
        uri, content = format_request(action, params)
        initheader    = http_auth_header(uri.to_s).merge(http_header).merge(initheader)
        response      = @http.post(uri.path, content, initheader)
        format_response(action, response)
      rescue Net::HTTPBadGateway, Errno::ECONNRESET, Errno::ECONNABORTED, SocketError => error
        format_error(error, error.message)
      end
  
      # Format Request data. It will be override by child class
      # == Arguments
      # * <tt>action</tt> -- Request action
      # * <tt>params</tt> -- Request parameters
      # == Return
      # * <tt>path</tt>   -- Formated request uri object
      # * <tt>params</tt> -- Formated request Parameters
      def format_request(action, params)
        [ @uri, params ]
      end
      
      # Format Response object. It will be override by child class
      # == Argument
      # * <tt>action</tt> -- Request action
      # * <tt>response</tt> -- HTTP response object
      def format_response(action, response)
        response
      end
      
      # Format Error object. It will be override by child class.
      # == Arguments
      # * <tt>exception</tt> -- Exception object.
      # * <tt>message</tt> -- Readable error message.
      def format_error(exception, message)
        raise exception
      end
    end    
  end
end