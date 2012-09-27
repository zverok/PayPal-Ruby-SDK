require 'spec_helper'

describe PayPal::SDK::Core::HTTP do

  HTTP = PayPal::SDK::Core::HTTP
 
  it "Create http object with default configuration" do
    http = HTTP.new
    http.address.should_not eql nil
    http.port.should_not eql nil
  end
  
  it "Create http object with given host and port" do
    http = HTTP.new("host_name", 4444)
    http.address.should eql "host_name"
    http.port.should eql 4444    
  end
     
  it "request paypal API service" do
    lambda {
      http      = HTTP.new(:development)
      response  = http.get("/AdaptivePayments/GetPaymentOptions")
    }.should_not raise_error
  end
  
  it "request paypal API service with ssl certificate" do
    lambda {
      http      = HTTP.new(:test)
      response  = http.get("/AdaptivePayments/GetPaymentOptions")
      http.ca_path.should eql nil
      http.ca_file.should eql http.config.cert_path
    }.should_not raise_error    
  end
  
  it "request paypal API service with ssl certificate" do
    lambda {
      http      = HTTP.new(:test, :cert_path => "spec/config")
      response  = http.get("/AdaptivePayments/GetPaymentOptions")
      http.ca_path.should eql http.config.cert_path
      http.ca_file.should eql nil
    }.should_not raise_error    
  end
  
end
