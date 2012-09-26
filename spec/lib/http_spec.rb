require 'spec_helper'

describe PayPal::SDK::Core::HTTP do

  HTTP = PayPal::SDK::Core::HTTP
    
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
    }.should_not raise_error    
  end
  
end
