require 'spec_helper'

describe PayPal::SDK::Core::API::Merchant do

  Merchant = PayPal::SDK::Core::API::Merchant

  TransactionSearchParams = { "StartDate" => "2012-09-30T00:00:00+0530", "EndDate" => "2012-09-30T00:01:00+0530"}

  it "make API call" do
    client    = Merchant.new
    response  = client.request("TransactionSearch", TransactionSearchParams )
    response["Ack"].should eql "Success"
  end

  it "make API call with ssl certificate" do
    client   = Merchant.new(:with_certificate)
    response  = client.request("TransactionSearch", TransactionSearchParams)
    response["Ack"].should eql "Success"
  end

  it "make API call with oauth token" do
    client   = Merchant.new(:with_oauth_token)
    response  = client.request("TransactionSearch", TransactionSearchParams)
    response["Ack"].should eql "Success"
  end

  describe "Format request" do

    before :all do
      @client    = Merchant.new
    end

    it "should handle :value member" do
      uri, request, http_header = @client.format_request("Action", :amount => { :value => "50" } )
      request.should match '<amount>50</amount>'
      uri, request, http_header = @client.format_request("Action", "amount" => { "value" => "50" } )
      request.should match '<amount>50</amount>'
    end

    it "should handle attribute" do
      uri, request, http_header = @client.format_request("Action", :amount => { :"@currencyID" => "USD", :value => "50" } )
      request.should match '<amount currencyID="USD">50</amount>'
      uri, request, http_header = @client.format_request("Action", "amount" => { "@currencyID" => "USD", "value" => "50" } )
      request.should match '<amount currencyID="USD">50</amount>'
    end

    it "should handle members" do
      uri, request, http_header = @client.format_request("Action", :list => { :amount => { :"@currencyID" => "USD", :value => "50" } } )
      request.should match '<list><amount currencyID="USD">50</amount></list>'
    end

    it "should handle array of members" do
      uri, request, http_header = @client.format_request("Action",
        :list => { :amount => [ { :"@currencyID" => "USD", :value => "50" }, { :"@currencyID" => "USD", :value => "25" } ] }  )
      request.should match '<list><amount currencyID="USD">50</amount><amount currencyID="USD">25</amount></list>'
    end

    it "should handle namespace" do
      uri, request, http_header = @client.format_request("Action", :"ebl:amount" => { :"@cc:currencyID" => "USD", :value => "50" } )
      request.should match '<ebl:amount cc:currencyID="USD">50</ebl:amount>'
    end
  end

  describe "Failure request" do

    def should_be_failure(response, message = nil)
      response.should_not be_nil
      response["Ack"].should eql "Failure"
      response["Errors"].should_not be_nil
      errors = response["Errors"].is_a?(Array) ? response["Errors"][0] : response["Errors"]
      errors["ShortMessage"].should match message if message
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
      should_be_failure(response)
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
