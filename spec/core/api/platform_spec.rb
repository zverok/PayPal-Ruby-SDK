require 'spec_helper'

describe PayPal::SDK::Core::API::Platform do

  Platform  = PayPal::SDK::Core::API::Platform
  ConvertCurrencyParams = {
          "baseAmountList"        => { "currency" => [ { "code" => "USD", "amount" => "2.0"} ]},
          "convertToCurrencyList" => { "currencyCode" => ["GBP"] } }
  CreateInvoiceParams   = {
    "invoice" => {
        "merchantEmail" => "sdk.token.test@paypal.com", "payerEmail" => "sender@yahoo.com",
        "itemList" => { "item" => [ { "name"=>"item1", "quantity"=>"1", "unitPrice"=>"1.00" },
                                    { "name"=>"item2", "quantity"=>"2", "unitPrice"=>"2.00" } ] },
        "currencyCode" => "USD", "paymentTerms" => "DueOnReceipt" } }

  describe "Configuration" do
    it "create client with Service name" do
      client = Platform.new("AdaptivePayments")
      client.uri.path.should match "AdaptivePayments$"
      client.service_name.should eql "AdaptivePayments"
    end

    it "service endpoint for sandbox" do
      sandbox_endpoint = "https://svcs.sandbox.paypal.com/"
      client = Platform.new("AdaptivePayments")
      client.service_endpoint.should eql sandbox_endpoint
      client = Platform.new("AdaptivePayments", :with_certificate)
      client.service_endpoint.should eql sandbox_endpoint
      client = Platform.new("AdaptivePayments", :mode => "sandbox")
      client.service_endpoint.should eql sandbox_endpoint
      client = Platform.new("AdaptivePayments", :mode => :sandbox)
      client.service_endpoint.should eql sandbox_endpoint
      client = Platform.new("AdaptivePayments", :mode => "invalid")
      client.service_endpoint.should eql sandbox_endpoint
      client = Platform.new("AdaptivePayments", :mode => nil)
      client.service_endpoint.should eql sandbox_endpoint
    end

    it "service endpoint for live" do
      live_endpoint = "https://svcs.paypal.com/"
      client = Platform.new("AdaptivePayments", :mode => "live")
      client.service_endpoint.should eql live_endpoint
      client = Platform.new("AdaptivePayments", :with_certificate, :mode => :live)
      client.service_endpoint.should eql live_endpoint
    end

    it "override service endpoint" do
      client = Platform.new("AdaptivePayments", :platform_end_point => "http://example.com" )
      client.service_endpoint.should eql "http://example.com"
      client = Platform.new("AdaptivePayments", :platform_end_point => "http://example.com", :mode => :live )
      client.service_endpoint.should eql "http://example.com"
      client = Platform.new("AdaptivePayments", :end_point => "http://example.com" )
      client.service_endpoint.should eql "http://example.com"
    end
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

    it "with proxy" do
      client   = Platform.new("AdaptivePayments", :with_proxy)
      response = client.request("ConvertCurrency", ConvertCurrencyParams)
      should_be_success(response)
    end

    describe "with token" do
      it "create invoice" do
        client   = Platform.new("Invoice", :with_oauth_token )
        response = client.request("CreateInvoice", CreateInvoiceParams)
        should_be_success(response)
      end

      it "get basic personal data" do
        client   = Platform.new("Permissions", :with_oauth_token )
        response = client.request("GetBasicPersonalData", { "attributeList" => { "attribute" => [
          "http://axschema.org/namePerson/first"
        ]}})
        should_be_success(response)
      end
    end

    describe "Override Configuration" do
      it "Set http_verify_mode" do
        api = Platform.new("AdaptivePayments", :http_verify_mode => 0 )
        api.http.verify_mode.should eql 0
      end
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


