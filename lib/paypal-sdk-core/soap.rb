require 'paypal-sdk-core/version'
require 'paypal-sdk-core/http'
require 'gyoku'
require 'nokogiri'
require 'nori'

module PayPal::SDK::Core
  class SOAP
    
    Namespaces = {
      "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
      "xmlns:urn"     => "urn:ebay:api:PayPalAPI",
      "xmlns:ebl"     => "urn:ebay:apis:eBLBaseComponents",
      "xmlns:cc"      => "urn:ebay:apis:CoreComponentTypes",
      "xmlns:ed"      => "urn:ebay:apis:EnhancedDataTypes"
    }
    Gyoku.convert_symbols_to :camelcase
        
    include PayPal::SDK::Core::Configuration
    include PayPal::SDK::Core::Logging
    
    attr_accessor :http, :uri
    
    def initialize(environment = nil, options = {})
      set_config(environment, options)
      @uri  = URI.parse(config.soap_end_point || config.end_point)
      @http = HTTP.new(@uri.host, @uri.port)
      @http.set_config(config)
    end

    def request(action, params = {})
      request_content = format_request(action, params)
      response        = @http.post(@uri.path, request_content)
      format_response(response, action)
    end
    
    def format_response(response, action)
      response_action = /#{Gyoku::XMLKey.create(action)}Response$/i
      hash = Nori.parse(response.body)
      hash = hash.find{|k,v| k.to_s =~ /Envelope$/i }.last    if hash.is_a? Hash
      hash = hash.find{|k,v| k.to_s =~ /Body$/i }.last        if hash.is_a? Hash
      hash = hash.find{|k,v| k.to_s =~ response_action }.last if hash.is_a? Hash
      hash || {}
    end           
   
    def format_request(action, params)
      Gyoku.xml({ 
        "soapenv:Envelope" => {
          "soapenv:Header"  => header,
          "soapenv:Body"    => body(action, params)
        },
        :attributes!       => { "soapenv:Envelope" => Namespaces }
      })
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
  end
end
