require 'spec_helper'

describe PayPal::SDK::Core::SOAP do
  SOAP = PayPal::SDK::Core::SOAP
      
  it "make API call" do
    client    = SOAP.new
    response  = client.request("TransactionSearch", { "StartDate" => "2012-09-30T00:00:00+0530",
         "EndDate" => "2012-10-01T00:00:00+0530"})
    response[:ack].should eql "Success"    
  end
  
  it "make API call with symbol as key" do
    client    = SOAP.new
    response  = client.request("TransactionSearch", { :start_date => "2012-09-30T00:00:00+0530",
         :end_date => "2012-10-01T00:00:00+0530"})
    response[:ack].should eql "Success"    
  end

  
  it "make API call with invalid params" do
    client    = SOAP.new
    response  = client.request("TransactionSearch")
    response[:ack].should eql "Failure"
  end
  
  it "API call with invalid credentials" do
    client    = SOAP.new(:username => "invalid")
    response  = client.request("TransactionSearch", { "StartDate" => "2012-09-30T00:00:00+0530",
         "EndDate" => "2012-10-01T00:00:00+0530"})
    response[:ack].should eql "Failure"
  end

  describe "Failure request" do
    
    TransactionSearchParams = { "StartDate" => "2012-09-30T00:00:00+0530", "EndDate" => "2012-10-01T00:00:00+0530"}
    
    def should_be_failure(response, message)
      response.should_not be_nil
      response[:ack].should eql "Failure"
      response[:errors].should_not be_nil
      response[:errors][:short_message].should match message            
    end
    
    it "invalid 3 token authentication" do
      client   = SOAP.new(:username => "invalid")
      response = client.request("TransactionSearch", TransactionSearchParams )
      should_be_failure(response, "Security error")
    end
    
    it "invalid ssl certificate authentication" do
      client   = SOAP.new(:with_certificate, :username => "invalid")
      response = client.request("TransactionSearch", TransactionSearchParams )
      should_be_failure(response, "Authorization Failed")
    end

    it "invalid end point" do
      client   = SOAP.new("https://invalid-api-3t.sandbox.paypal.com/2.0/")
      response = client.request("TransactionSearch", TransactionSearchParams )
      should_be_failure(response, "No such host is known")
    end
    
    it "with nvp endpoint" do
      client   = SOAP.new("https://svcs.sandbox.paypal.com/AdaptivePayments")
      response = client.request("TransactionSearch", TransactionSearchParams )
      should_be_failure(response, "Internal Server Error")      
    end
    
    it "invalid action" do
      client   = SOAP.new
      response = client.request("InvalidAction", TransactionSearchParams )
      should_be_failure(response, "Internal Server Error")
    end
    
    it "invalid params" do
      client   = SOAP.new
      response = client.request("TransactionSearch", { :invalid_params => "something" } )
      should_be_failure(response, "invalid argument")
    end

  end    
  
end
