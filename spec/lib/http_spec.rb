require 'spec_helper'

describe PayPal::SDK::Core::HTTP do

  HTTP = PayPal::SDK::Core::HTTP
 
  it "Create http object with given host and port" do
    host_name   = "host_name"
    port_number = 444
    http = HTTP.new(host_name, port_number)
    http.address.should eql host_name
    http.port.should    eql port_number    
  end
     
  it "request paypal API service" do
    lambda {
      uri       = URI.parse("https://svcs.sandbox.paypal.com/")
      http      = HTTP.new(uri.host, uri.port)
      response  = http.post("/AdaptivePayments/GetPaymentOptions", "")
      response.body.should_not match "Authentication failed"
    }.should_not raise_error
  end
  
  it "request paypal API service with ssl certificate" do
    lambda {
      uri       = URI.parse("https://svcs.sandbox.paypal.com/")
      http      = HTTP.new(uri.host, uri.port)
      http.set_config(:with_certificate)
      response  = http.post("/AdaptivePayments/GetPaymentOptions", "")
      http.cert.should_not be_nil
      response.body.should_not match "Authentication failed"
    }.should_not raise_error    
  end
    
end
