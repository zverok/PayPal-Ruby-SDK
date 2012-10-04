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
  
  it "format soap body" do
    client    = SOAP.new
    soap_body = client.body(:transaction_search, { :start_date => "2012-09-30T00:00:00+0530",
        :end_date => "2012-10-01T00:00:00+0530"})
    soap_body.to_s.should match "TransactionSearch"
    soap_body.to_s.should match "StartDate"
    soap_body.to_s.should match "EndDate"
  end 
    
  it "make API call" do
    client    = SOAP.new(:development)
    response  = client.request("TransactionSearch", { "StartDate" => "2012-09-30T00:00:00+0530",
         "EndDate" => "2012-10-01T00:00:00+0530"})
    response["Ack"].should eql "Success"    
  end
  
end
