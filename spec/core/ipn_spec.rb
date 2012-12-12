require 'spec_helper'

describe PayPal::SDK::Core::IPN do

  IPN = PayPal::SDK::Core::IPN

  describe "Configuration" do
    it "set IPN end_point" do
      ipn_validate_url = "https://www.sandbox.paypal.com/cgi-bin/webscr"
      message = IPN::Message.new(samples["ipn"]["valid_message"], :ipn_end_point => ipn_validate_url )
      message.config.ipn_end_point.should eql ipn_validate_url
    end
  end

  describe "Valid" do
    it "request" do
      response = IPN.request(samples["ipn"]["valid_message"])
      response.body.should eql IPN::VERIFIED
    end

    it "valid?" do
      response = IPN.valid?(samples["ipn"]["valid_message"])
      response.should be_true
    end
  end

  describe "Invalid" do
    it "request" do
      response = IPN.request(samples["ipn"]["invalid_message"])
      response.body.should eql IPN::INVALID
    end

    it "valid?" do
      response = IPN.valid?(samples["ipn"]["invalid_message"])
      response.should be_false
    end
  end

end
