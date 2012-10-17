require 'gyoku'
require 'nori'


module PayPal::SDK::Core
  
  module API
  
    # Use SOAP protocol to communicate with the Merchant Web services
    # == Example
    #   api       = API::Merchant.new
    #   response  = api.request("TransactionSearch", { "StartDate" => "2012-09-30T00:00:00+0530",
    #      "EndDate" => "2012-10-01T00:00:00+0530" })
    class Merchant < Base
      
      Namespaces = {
        "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
        "xmlns:urn"     => "urn:ebay:api:PayPalAPI",
        "xmlns:ebl"     => "urn:ebay:apis:eBLBaseComponents",
        "xmlns:cc"      => "urn:ebay:apis:CoreComponentTypes",
        "xmlns:ed"      => "urn:ebay:apis:EnhancedDataTypes"
      }
      XML_OPTIONS       = { :namespace => "urn", :element_form_default => :qualified }
      DEFAULT_PARAMS    = { "ebl:Version" => API_VERSION }
      SOAP_HTTP_AUTH_HEADER  = {
        :authorization  => "X-PP-AUTHORIZATION"
      }
      SOAP_AUTH_HEADER  = {
        :username   => "ebl:Username",
        :password   => "ebl:Password",
        :signature  => "ebl:Signature",
        :subject    => "ebl:Subject"
      }
      
      Gyoku.convert_symbols_to :camelcase
      Nori.configure do |config|
        config.strip_namespaces = true
        config.convert_tags_to { |tag| tag.snakecase.to_sym }
      end
      
      # Get SOAP or default end point
      def service_endpoint
        config.merchant_end_point || super || default_end_point(:merchant)
      end
      
      # Format the HTTP request content
      # === Arguments
      # * <tt>action</tt> -- Request action
      # * <tt>params</tt> -- Parameters for Action in Hash format
      # === Return
      # * <tt>request_path</tt> -- Soap request path. DEFAULT("/")
      # * <tt>request_content</tt> -- Request content in SOAP format.
      def format_request(action, params)
        credential_properties  = credential(uri.to_s).properties
        user_auth_header = map_header_value(SOAP_AUTH_HEADER, credential_properties)
        request_content = Gyoku.xml({ 
          "soapenv:Envelope" => {
            "soapenv:Header"  => { "urn:RequesterCredentials" => {
                "ebl:Credentials" => user_auth_header
             } },
            "soapenv:Body"    => body(action, params)
          },
          :attributes!       => { "soapenv:Envelope" => Namespaces }
        }, XML_OPTIONS)
        header = map_header_value(SOAP_HTTP_AUTH_HEADER, credential_properties)
        [ @uri, request_content, header ]
      end
      
      # Format Response object
      # === Arguments
      # * <tt>action</tt> -- Request action
      # * <tt>response</tt> -- Response object
      # === Return
      # Parse the SOAP response content and return Hash object
      def format_response(action, response)
        if response.code == "200"
          response_action = "#{action.snakecase}_response".to_sym
          hash = Nori.parse(response.body)
          hash[:envelope][:body][response_action]
        else
          format_error(response, response.message)
        end
      end           
     
      private
          
      # Generate soap body
      # == Arguments
      # * <tt>action</tt> -- Request Action name
      # * <tt>params</tt> -- Parameters for the action.
      def body(action, params = {})
        action = Gyoku::XMLKey.create(action, XML_OPTIONS)
        { "#{action}Req" => { "#{action}Request" => DEFAULT_PARAMS.merge(params) } }
      end
  
      # Format Error object.
      # == Arguments
      # * <tt>exception</tt> -- Exception object or HTTP response object.
      # * <tt>message</tt> -- Readable error message.
      def format_error(exception, message)
        { :ack => "Failure", :errors => { :short_message => message, :long_message => message, :exception => exception } }
      end
    end
  end
end
