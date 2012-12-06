require 'spec_helper'

describe PayPal::SDK::Core::IPN do

  IPN = PayPal::SDK::Core::IPN

  describe "Invalid" do
    it "request" do
      response = IPN.request("message=something")
      response.body.should eql IPN::INVALID
    end

    it "verify?" do
      response = IPN.verify?("message=something")
      response.should be_false
    end
  end

end
