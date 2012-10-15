require "paypal-sdk-core/version"
require "paypal-sdk-core/config"
require "paypal-sdk-core/logging"

module PayPal
  module SDK
    module Core
      
      autoload :Authentication, "paypal-sdk-core/authentication"
      autoload :SOAP, "paypal-sdk-core/soap"
      autoload :NVP,  "paypal-sdk-core/nvp"
      
      module Util
        autoload :OauthSignature, "paypal-sdk-core/util/oauth_signature"
      end
      
      module Credential
        
        autoload :Base,         "paypal-sdk-core/credential/base"
        autoload :Certificate,  "paypal-sdk-core/credential/certificate"
        autoload :Signature,    "paypal-sdk-core/credential/signature"
        
        module ThirdParty
          autoload :Token,    "paypal-sdk-core/credential/third_party/token"
          autoload :Subject,  "paypal-sdk-core/credential/third_party/subject"
        end
        
      end
      
      def self.included(klass)
        klass.class_eval do 
          include Logging
          include Configuration
        end
      end
      
    end
  end
end