require 'spec_helper'

describe PayPal::SDK::Core::API::Merchant do
  
  Merchant = PayPal::SDK::Core::API::Merchant
  
  TransactionSearchParams = { "StartDate" => "2012-09-30T00:00:00+0530", "EndDate" => "2012-10-01T00:00:00+0530"}

  it "make API call" do
    client    = Merchant.new
    response  = client.request("TransactionSearch", TransactionSearchParams )
    response[:ack].should eql "Success"    
  end
  
  it "make API call with symbol as key" do
    client    = Merchant.new
    response  = client.request("TransactionSearch", { :start_date => "2012-09-30T00:00:00+0530", :end_date => "2012-10-01T00:00:00+0530" })
    response[:ack].should eql "Success"    
  end
  
  it "make API call with ssl certificate" do
    client   = Merchant.new(:with_certificate)
    response  = client.request("TransactionSearch", TransactionSearchParams)
    response[:ack].should eql "Success"
  end
  
  it "make API call with oauth token" do
    client   = Merchant.new(:with_oauth_token)
    response  = client.request("TransactionSearch", TransactionSearchParams)
    response[:ack].should eql "Success"
  end

  describe "Failure request" do
    
    def should_be_failure(response, message)
      response.should_not be_nil
      response[:ack].should eql "Failure"
      response[:errors].should_not be_nil
      response[:errors][:short_message].should match message            
    end
    
    it "invalid 3 token authentication" do
      client   = Merchant.new(:username => "invalid")
      response = client.request("TransactionSearch", TransactionSearchParams )
      should_be_failure(response, "Security error")
    end
    
    it "invalid ssl certificate authentication" do
      client   = Merchant.new(:with_certificate, :username => "invalid")
      response = client.request("TransactionSearch", TransactionSearchParams )
      should_be_failure(response, "Authorization Failed")
    end

    it "invalid end point" do
      client   = Merchant.new(:merchant_end_point => "https://invalid-api-3t.sandbox.paypal.com/2.0/")
      response = client.request("TransactionSearch", TransactionSearchParams )
      should_be_failure(response, "No such host is known")
    end
    
    it "with nvp endpoint" do
      client   = Merchant.new(:merchant_end_point => "https://svcs.sandbox.paypal.com/AdaptivePayments")
      response = client.request("TransactionSearch", TransactionSearchParams )
      should_be_failure(response, "Internal Server Error")      
    end
    
    it "invalid action" do
      client   = Merchant.new
      response = client.request("InvalidAction", TransactionSearchParams )
      should_be_failure(response, "Internal Server Error")
    end
    
    it "invalid params" do
      client   = Merchant.new
      response = client.request("TransactionSearch", { :invalid_params => "something" } )
      should_be_failure(response, "invalid argument")
    end

  end    
  
end
