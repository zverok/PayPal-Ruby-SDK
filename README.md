# Paypal::Sdk::Core

Core library for PayPal ruby SDK.

## Installation

Add this line to your application's Gemfile:

    gem 'paypal-sdk-core', :git => "https://github.com/paypal/sdk-core.git", :branch => "ruby-sdk"

And then execute:

    $ bundle
    
Run Testcase

    $ bundle exec rspec


## Usage

```ruby
# Load Configurations from file
PayPal::SDK::Core::Config.load('config/paypal.yml', 'development')

# Get Configuration
config = PayPal::SDK::Core::Config.config # Load default configuration
config = PayPal::SDK::Core::Config.config(:development) # Load specified environment configuration
config = PayPal::SDK::Core::Config.config(:development, :app_id => "XYZ") # Override configuration

# Include Core package
include PayPal::SDK::Core
set_config :development # Set configuration
config  				# access configuration
logger  				# access logger

# To make Platform API call
client   = PayPal::SDK::Core::API::Platform.new
response = client.request("TransactionSearch", { 
    "StartDate" => "2012-09-30T00:00:00+0530", "EndDate" => "2012-10-01T00:00:00+0530" })

# To make Merchant API call
client    = PayPal::SDK::Core::API::Merchant.new("AdaptivePayments")
response  = client.request("ConvertCurrency", {
    "baseAmountList"        => { "currency" => [ { "code" => "USD", "amount" => "2.0"} ]},
    "convertToCurrencyList" => { "currencyCode" => ["GBP"] } })
```

# Implement AdaptivePayments by inheriting the Platform class

```ruby
class AdaptivePayments < PayPal::SDK::Core::API::Platform
  def initlaize(*args)
    super("AdaptivePayments", *args)
  end
  
  def currency_convert(object, http_headers = {})
    object   = ConvertCurrencyRequest.new(object) unless object.is_a? ConvertCurrencyRequest
    response = request("ConvertCurrency", object.to_hash, http_headers)
    ConvertCurrencyResponse.new(response)
  end
  ....
end

# Using AdaptivePayments class
ap = AdaptivePayment.new
response = ap.currency_convert( {...} )
response.response_envelope.ack
```