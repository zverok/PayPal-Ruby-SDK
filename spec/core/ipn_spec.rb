require 'spec_helper'

describe PayPal::SDK::Core::IPN do

  IPN = PayPal::SDK::Core::IPN

  describe "Valid" do
    it "request" do
      response = IPN.request(samples["ipn"]["valid_message"])
      response.body.should eql IPN::VERIFIED
    end

    it "verify?" do
      response = IPN.verify?(samples["ipn"]["valid_message"])
      response.should be_true
    end
  end

  describe "Invalid" do
    it "request" do
      response = IPN.request(samples["ipn"]["invalid_message"])
      response.body.should eql IPN::INVALID
    end

    it "verify?" do
      response = IPN.verify?(samples["ipn"]["invalid_message"])
      response.should be_false
    end
  end

end
