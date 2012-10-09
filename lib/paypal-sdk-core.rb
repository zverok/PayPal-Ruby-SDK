require "paypal-sdk-core/version"
require "paypal-sdk-core/config"
require "paypal-sdk-core/logging"
require "paypal-sdk-core/authentication"
require "paypal-sdk-core/soap"
require "paypal-sdk-core/nvp"

module PayPal
  module SDK
    module Core
      def self.included(klass)
        klass.class_eval do 
          include Logging
          include Configuration
        end
      end
    end
  end
end