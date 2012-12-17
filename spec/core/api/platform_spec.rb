require 'spec_helper'

describe PayPal::SDK::Core::API::Platform do

  Platform  = PayPal::SDK::Core::API::Platform
  ConvertCurrencyParams = {
          "baseAmountList"        => { "currency" => [ { "code" => "USD", "amount" => "2.0"} ]},
          "convertToCurrencyList" => { "currencyCode" => ["GBP"] } }
  CreateInvoiceParams   = {
    "invoice" => {
        "merchantEmail" => "platfo_1255077030_biz@gmail.com", "payerEmail" => "sender@yahoo.com",
        "itemList" => { "item" => [ { "name"=>"item1", "quantity"=>"1", "unitPrice"=>"1.00" },
                                    { "name"=>"item2", "quantity"=>"2", "unitPrice"=>"2.00" } ] },
        "currencyCode" => "USD", "paymentTerms" => "DueOnReceipt" } }

  it "create client with Service name" do
    client = Platform.new("AdaptivePayments")
    client.uri.path.should match "AdaptivePayments$"
  end

  describe "Success request" do
    def should_be_success(response)
      response.should_not be_nil
      response["responseEnvelope"].should_not be_nil
      response["responseEnvelope"]["ack"].should eql "Success"
    end

    it "with default configuration" do
      client   = Platform.new("AdaptivePayments")
      response = client.request("ConvertCurrency", ConvertCurrencyParams)
      should_be_success(response)
    end

    it "with certificate authentication" do
      client   = Platform.new("AdaptivePayments", :with_certificate)
      response = client.request("ConvertCurrency", ConvertCurrencyParams)
      should_be_success(response)
    end

    it "with oauth token" do
      client   = Platform.new("Invoice", :with_oauth_token )
      response = client.request("CreateInvoice", CreateInvoiceParams)
      should_be_success(response)
    end

    it "with proxy" do
      client   = Platform.new("AdaptivePayments", :with_proxy)
      response = client.request("ConvertCurrency", ConvertCurrencyParams)
      should_be_success(response)
    end
  end

  describe "Failure request" do
    def should_be_failure(response, message = nil)
      response.should_not be_nil
      response["responseEnvelope"].should_not be_nil
      response["responseEnvelope"]["ack"].should eql "Failure"
      response["error"][0]["message"].should match message if message
    end

    it "invalid 3 token authentication" do
      client   = Platform.new("AdaptivePayments", :password => "invalid")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "Authentication failed")
    end

    it "invalid ssl certificate authentication" do
      client   = Platform.new("AdaptivePayments", :with_certificate, :username => "invalid")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "Authentication failed")
    end

    it "invalid action" do
      client   = Platform.new("AdaptivePayments")
      response = client.request("InvalidAction", ConvertCurrencyParams)
      should_be_failure(response, "Internal Server Error")
    end

    it "invalid params" do
      client   = Platform.new("AdaptivePayments")
      response = client.request("ConvertCurrency", { "inValidCurrencyParams" => {} })
      should_be_failure(response, "Invalid request parameter")
    end
  end

end


