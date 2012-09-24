require 'spec_helper'

describe PayPal::SDK::Core::Config do
  
  Config = PayPal::SDK::Core::Config
  
  it "load configuration file" do
    lambda { 
      Config.load("spec/config/paypal.yml", "test")
    }.should_not raise_error
  end
    
  it "return default environment configuration" do
    Config.config.should be_a Config
  end
  
  it "return configuration based on environment" do
    Config.config(:development).should be_a Config
  end
  
  it "override default configuration" do
    override_configuration = { :username => "test.example.com", :app_id => "test"}
    config = Config.config(override_configuration)
    
    config.username.should eql(override_configuration[:username])
    config.app_id.should eql(override_configuration[:app_id])    
  end
  
end