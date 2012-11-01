# Paypal::Sdk::Core

Core library for PayPal ruby SDK.

## Installation

Add this line to your application's Gemfile:

    gem 'paypal-sdk-core', :git => "https://github.com/paypal/sdk-core.git", :branch => "ruby-sdk"

And then execute:

    $ bundle

Run Testcase

    $ bundle exec rspec

## Configuration
The Core library will try to load the configuration from default location `config/paypal.yml` and environment `development`

```yaml
development: &default
  username: jb-us-seller_api1.paypal.com
  password: WX4WTU3S8MY44S7F
  signature: AFcWxV21C7fd0v3bYYYRCpSSRl31A7yDhhsPUU2XhtMoZXsWHFxu-RWy
  app_id: APP-80W284485P519543T
  http_timeout: 30
  http_retry: 5
  http_trust: false
  mode: sandbox
test:
  <<: *default
production:
  mode: live
  ...
```

Load Configurations from specified file:

```ruby
PayPal::SDK::Core::Config.load('config/paypal.yml',  ENV['RACK_ENV'] || 'development')
```

Override configuration on particular API client:

```ruby
client    = PayPal::SDK::Core::API::Platform.new("AdaptivePayments", :test, :app_id => "XYZ")
# Override with default environment configuration
client    = PayPal::SDK::Core::API::Platform.new("AdaptivePayments", :app_id => "XYZ")
```

Change client API configuration

```ruby
client.set_config :development
client.set_config :development, :api_id => "XYZ"
```

## Usage API services


```ruby

# To make Merchant API call
client   = PayPal::SDK::Core::API::Merchant.new
response = client.request("TransactionSearch", {
    "StartDate" => "2012-09-30T00:00:00+0530", "EndDate" => "2012-10-01T00:00:00+0530" })

# To make Platform API call
client    = PayPal::SDK::Core::API::Platform.new("AdaptivePayments")
response  = client.request("ConvertCurrency", {
    "baseAmountList"        => { "currency" => [ { "code" => "USD", "amount" => "2.0"} ]},
    "convertToCurrencyList" => { "currencyCode" => ["GBP"] } })
```

## Using Core class

```ruby
# Get Configuration
config = PayPal::SDK::Core::Config.config # Load default configuration
config = PayPal::SDK::Core::Config.config(:development) # Load specified environment configuration
config = PayPal::SDK::Core::Config.config(:development, :app_id => "XYZ") # Override configuration

# Include Core package
include PayPal::SDK::Core::Configuration
include PayPal::SDK::Core::Logging
set_config :development # Set configuration
config  				# access configuration
logger  				# access logger
```

## Implement AdaptivePayments by inheriting the Platform class

```ruby
class AdaptivePayments < PayPal::SDK::Core::API::Platform

  def initlaize(*args)
    super("AdaptivePayments", *args)
  end

  def convert_currency(object_or_hash, http_headers = {})
    object_or_hash = ConvertCurrencyRequest.new(object_or_hash) unless object_or_hash.is_a? ConvertCurrencyRequest
    response_hash  = request("ConvertCurrency", object_or_hash.to_hash, http_headers)
    ConvertCurrencyResponse.new(response_hash)
  end
  ....
end

# Using AdaptivePayments class
ap = AdaptivePayment.new
response = ap.convert_currency( {...} )
response.response_envelope.ack
```
