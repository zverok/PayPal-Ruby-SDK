module PayPal::SDK::Core
  module Credential
    
    # Base credential Class for authentication
    class Base
      attr_accessor :username, :password, :app_id
      
      # Initialize authentication configurations
      # === Arguments
      #  * <tt>config</tt> -- Configuration object
      def initialize(config)
        self.username = config.username
        self.password = config.password 
        self.app_id   = config.app_id
      end
      
      # Return credential properties
      def properties
        { :username => username, :password => password, :app_id => app_id }
      end
      
    end
  end
end