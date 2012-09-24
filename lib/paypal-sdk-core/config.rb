require 'erb'
require 'yaml'

class PayPal::SDK::Core::Config
  
  attr_accessor :username, :password, :signature, :app_id,
      :cert_key, :cert_path,
      :http_timeout, :http_retry, :http_trust, :http_proxy,
      :end_point, :redirect_url, :dev_central_url
  
  def initialize(options)
    options.each do |key, value|
      send("#{key}=", value) rescue nil
    end
  end
  
  class << self
    def load(file_name, default_environment = "development")
      @@configurations      = self.read_configurations(file_name)
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
      override_configuration = configurations[env.to_s].dup.merge override_configuration
      new(override_configuration)
    end
  end
  
end