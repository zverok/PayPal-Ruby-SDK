require 'spec_helper'

describe PayPal::SDK::Core::OpenIDConnect do
  OpenIDConnect = PayPal::SDK::Core::OpenIDConnect

  it "generate autorize_url" do
    OpenIDConnect.set_config( :client_id => "client_id", :openid_redirect_uri => "http://google.com" )
    url = OpenIDConnect::Authorizeinfo.authorize_url
    url.should match "client_id=client_id"
    url.should match Regexp.escape("redirect_uri=#{CGI.escape("http://google.com")}")
    url.should match "scope=openid"
  end

  it "Override authorize_url" do
    url = OpenIDConnect::Authorizeinfo.authorize_url(
      :client_id => "new_client_id",
      :redirect_uri => "http://example.com",
      :scope => "openid profile")
    url.should match "client_id=new_client_id"
    url.should match Regexp.escape("redirect_uri=#{CGI.escape("http://example.com")}")
    url.should match Regexp.escape("scope=#{CGI.escape("openid profile")}")
  end

  it "Create token" do
    lambda{
      tokeninfo = OpenIDConnect::Tokeninfo.create("invalid-autorize-code")
    }.should raise_error PayPal::SDK::Core::Exceptions::BadRequest
  end

  it "Refresh token" do
    lambda{
      tokeninfo = OpenIDConnect::Tokeninfo.refresh("invalid-refresh-token")
    }.should raise_error PayPal::SDK::Core::Exceptions::BadRequest
  end

  it "Get userinfo" do
    lambda{
      userinfo = OpenIDConnect::Userinfo.get("invalid-access-token")
    }.should raise_error PayPal::SDK::Core::Exceptions::UnauthorizedAccess
  end

end
