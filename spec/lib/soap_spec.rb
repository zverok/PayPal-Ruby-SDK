require 'spec_helper'

describe PayPal::SDK::Core::SOAP do
  SOAP = PayPal::SDK::Core::SOAP
  it "create a client object" do
    client = SOAP.new
    client.http.should be_a PayPal::SDK::Core::HTTP
    client.config.should eql client.http.config
  end
  
  it "create a client object based on environment" do
    client = SOAP.new(:development)
    client.http.should be_a PayPal::SDK::Core::HTTP
    client.config.should eql client.http.config
  end
      
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
  
end
