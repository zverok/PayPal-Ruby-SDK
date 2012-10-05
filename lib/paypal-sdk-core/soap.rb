require 'paypal-sdk-core/version'
require 'paypal-sdk-core/api'
require 'gyoku'
require 'nori'


module PayPal::SDK::Core
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
    
    def service_endpoint
      config.soap_end_point || super
    end
    
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
    
    def header
      { "urn:RequesterCredentials" => {
          "ebl:Credentials" => {
            "ebl:Username"  => config.username,
            "ebl:Password"  => config.password,
            "ebl:Signature" => config.signature         
      } } }
    end
    
    def body(action, params = {})
      action = Gyoku::XMLKey.create(action, XML_OPTIONS)
      { "#{action}Req" => { "#{action}Request" => params.merge(DEFAULT_PARAMS) } }
    end

    def format_response(action, response)
      response_action = "#{action.snakecase}_response".to_sym
      hash = Nori.parse(response.body)
      hash[:envelope][:body][response_action]
    end           
   
  end
end
