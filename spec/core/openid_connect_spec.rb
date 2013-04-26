require 'spec_helper'

describe PayPal::SDK::OpenIDConnect do
  OpenIDConnect = PayPal::SDK::OpenIDConnect

  before :all do
    OpenIDConnect.set_config( :client_id => "client_id", :openid_redirect_uri => "http://google.com" )
  end

  it "Validate user_agent" do
    OpenIDConnect::API.user_agent.should match "PayPalSDK/openid-connect-ruby"
  end

  it "generate autorize_url" do
    url = OpenIDConnect::Tokeninfo.authorize_url
    url.should match "client_id=client_id"
    url.should match Regexp.escape("redirect_uri=#{CGI.escape("http://google.com")}")
    url.should match "scope=openid"
  end

  it "Override authorize_url params" do
    url = OpenIDConnect.authorize_url(
      :client_id => "new_client_id",
      :redirect_uri => "http://example.com",
      :scope => "openid profile")
    url.should match "client_id=new_client_id"
    url.should match Regexp.escape("redirect_uri=#{CGI.escape("http://example.com")}")
    url.should match Regexp.escape("scope=#{CGI.escape("openid profile")}")
  end

  it "Generate logout_url" do
    url = OpenIDConnect.logout_url
    url.should match "logout=true"
    url.should match Regexp.escape("redirect_uri=#{CGI.escape("http://google.com")}")
    url.should_not match "id_token"
  end

  it "Override logout_url params" do
    url = OpenIDConnect.logout_url({
      :redirect_uri => "http://example.com",
      :id_token  => "testing" })
    url.should match Regexp.escape("redirect_uri=#{CGI.escape("http://example.com")}")
    url.should match "id_token=testing"
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

  describe "Tokeninfo" do
    before do
      @tokeninfo = OpenIDConnect::Tokeninfo.new( :access_token => "test_access_token",
        :refresh_token => "test_refresh_token",
        :id_token => "test_id_token" )
    end

    it "refresh" do
      lambda{
        tokeninfo = @tokeninfo.refresh
      }.should raise_error PayPal::SDK::Core::Exceptions::BadRequest
    end

    it "userinfo" do
      lambda{
        userinfo = @tokeninfo.userinfo
      }.should raise_error PayPal::SDK::Core::Exceptions::UnauthorizedAccess
    end

    it "Generate logout_url" do
      url = @tokeninfo.logout_url
      url.should match "id_token=test_id_token"
      url.should match "logout=true"
      url.should match Regexp.escape("redirect_uri=#{CGI.escape("http://google.com")}")
    end
  end


end
