require 'spec_helper'

describe PayPal::SDK::Core::Config do

  Config = PayPal::SDK::Core::Config

  it "load configuration file and default environment" do
    lambda {
      Config.load("spec/config/paypal.yml", "test")
      Config.default_environment.should eql "test"
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

  it "get cached config" do
    Config.config(:test).should eql Config.config(:test)
    Config.config(:test).should_not eql Config.config(:development)
  end

  it "should raise error on invalid environment" do
    lambda {
      Config.config(:invalid_env)
    }.should raise_error "Configuration[invalid_env] NotFound"
  end

  it "set logger" do
    require 'logger'
    my_logger = Logger.new(STDERR)
    Config.logger = my_logger
    Config.logger.should eql my_logger
  end

end
