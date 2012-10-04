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
    Gyoku.convert_symbols_to :camelcase
    
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
      })
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
      key_options = { :namespace => "urn", :element_form_default => :qualified }
      action = Gyoku::XMLKey.create(action, key_options)
      params = params.map{|key,val| [Gyoku::XMLKey.create(key, key_options), val] }
      params.unshift(["ebl:Version", API_VERSION])
      { "#{action}Req" => { "#{action}Request" => Hash[params] } }
    end

    def format_response(action, response)
      response_action = /#{Gyoku::XMLKey.create(action)}Response$/i
      hash = Nori.parse(response.body)
      hash = hash.find{|k,v| k.to_s =~ /Envelope$/i }.last    if hash.is_a? Hash
      hash = hash.find{|k,v| k.to_s =~ /Body$/i }.last        if hash.is_a? Hash
      hash = hash.find{|k,v| k.to_s =~ response_action }.last if hash.is_a? Hash
      hash || {}
    end           
   
  end
end
