require 'erb'
require 'yaml'

module PayPal::SDK::Core
  
  module Configuration
    def config
      @config ||= Config.config
    end
    
    def config=(env, *args)
      @config = env.is_a?(Config) ? env : Config.config(env, *args)
    end
    
    alias_method :set_config, :config=
  end
  
  class Config    
    attr_accessor :username, :password, :signature, :app_id,
        :cert_key, :cert_path,
        :http_timeout, :http_retry, :http_trust, :http_proxy,
        :end_point, :redirect_url, :dev_central_url,
        :logfile
    
    def initialize(options)
      options.each do |key, value|
        send("#{key}=", value) rescue nil
      end
    end
        
    class << self
      
      @@config_cache = {}
      
      def load(file_name, default_environment = "development")
        @@configurations      = read_configurations(file_name)
        @@default_environment = default_environment
      end
      
      def read_configurations(file_name = "config/paypal.yml")
        YAML.load(ERB.new(File.read(file_name)).result)
      end
      
      def default_environment
        @@default_environment ||= "development"
      end
      
      def configurations
        @@configurations ||= read_configurations
      end
      
      def config(env = default_environment, override_configuration = {})
        if env.is_a? Hash
          override_configuration = env
          env = default_environment
        end
        env = env.to_s
        raise "Configuration[#{env}] NotFound" unless configurations[env]
        if override_configuration.nil? or override_configuration.empty?
          @@config_cache[env] ||= new configurations[env]
        else
          new configurations[env].merge(override_configuration)
        end
      end
    end
  end
end