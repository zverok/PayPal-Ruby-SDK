require 'spec_helper'

describe PayPal::SDK::Core do
  
  before :all do
    ExampleClass = Class.new{ include PayPal::SDK::Core }
  end
  
  it "should include config and logger" do
    example = ExampleClass.new
    example.config.should be_a PayPal::SDK::Core::Config
    example.logger.should be_a Logger
  end
  
end
