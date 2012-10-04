require 'spec_helper'

describe PayPal::SDK::Core::NVP do
  
  NVP = PayPal::SDK::Core::NVP
  
  it "create nvp client" do
    client = NVP.new
    client.http.should    be_a PayPal::SDK::Core::HTTP
    client.config.should  eql client.http.config
  end
  
  it "create nvp client with prefix url" do
    client = NVP.new("AdaptivePayments")
    client.uri.path.should match "AdaptivePayments$"
  end
  
  it "make AdaptivePayments API request" do
    client   = NVP.new("AdaptivePayments")
    response = client.request("ConvertCurrency", {
        "requestEnvelope"       => { "errorLanguage" => "en_US" }, 
        "baseAmountList"        => { "currency" => [ { "code" => "USD", "amount" => "2.0"} ]},
        "convertToCurrencyList" => { "currencyCode" => ["GBP"] }
    })
    response.should_not be_nil
    response["responseEnvelope"].should_not be_nil
    response["responseEnvelope"]["ack"].should eql "Success"
  end
  
end
