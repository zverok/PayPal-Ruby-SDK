require 'paypal-sdk-core/version'
require 'paypal-sdk-core/api'
require 'gyoku'
require 'nori'


module PayPal::SDK::Core
  
  # Use SOAP protocol to communicate with the Web services
  # == Example
  #   api       = SOAP.new
  #   response  = api.request("TransactionSearch", { "StartDate" => "2012-09-30T00:00:00+0530",
  #      "EndDate" => "2012-10-01T00:00:00+0530" })
  class SOAP < API
    
    Namespaces = {
      "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
      "xmlns:urn"     => "urn:ebay:api:PayPalAPI",
      "xmlns:ebl"     => "urn:ebay:apis:eBLBaseComponents",
      "xmlns:cc"      => "urn:ebay:apis:CoreComponentTypes",
      "xmlns:ed"      => "urn:ebay:apis:EnhancedDataTypes"
    }
    XML_OPTIONS     = { :namespace => "urn", :element_form_default => :qualified }
    DEFAULT_PARAMS  = { "ebl:Version" => API_VERSION }  
    
    Gyoku.convert_symbols_to :camelcase
    Nori.configure do |config|
      config.strip_namespaces = true
      config.convert_tags_to { |tag| tag.snakecase.to_sym }
    end
    
    # Get SOAP or default end point
    def service_endpoint
      config.soap_end_point || super
    end
    
    # Format the HTTP request content
    # === Arguments
    # * <tt>action</tt> -- Request action
    # * <tt>params</tt> -- Parameters for Action in Hash format
    # === Return
    # * <tt>request_path</tt> -- Soap request path. DEFAULT("/")
    # * <tt>request_content</tt> -- Request content in SOAP format.
    def format_request(action, params)
      request_content = Gyoku.xml({ 
        "soapenv:Envelope" => {
          "soapenv:Header"  => header,
          "soapenv:Body"    => body(action, params)
        },
        :attributes!       => { "soapenv:Envelope" => Namespaces }
      }, XML_OPTIONS)
      [ @uri.path, request_content ]
    end
    
    # Format Response object
    # === Arguments
    # * <tt>action</tt> -- Request action
    # * <tt>response</tt> -- Response object
    # === Return
    # Parse the SOAP response content and return Hash object
    def format_response(action, response)
      response_action = "#{action.snakecase}_response".to_sym
      hash = Nori.parse(response.body)
      hash[:envelope][:body][response_action]
    end           
   
    private
    
    # Default soap header
    def header
      { "urn:RequesterCredentials" => {
          "ebl:Credentials" => {
            "ebl:Username"  => config.username,
            "ebl:Password"  => config.password,
            "ebl:Signature" => config.signature         
      } } }
    end
    
    # Generate soap body
    # == Arguments
    # * <tt>action</tt> -- Request Action name
    # * <tt>params</tt> -- Parameters for the action.
    def body(action, params = {})
      action = Gyoku::XMLKey.create(action, XML_OPTIONS)
      { "#{action}Req" => { "#{action}Request" => DEFAULT_PARAMS.merge(params) } }
    end

  end
end
