# Paypal::Sdk::Core

Core library for PayPal ruby SDK.

## Installation

Add this line to your application's Gemfile:

    gem 'paypal-sdk-core'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paypal-sdk-core

## Usage

```ruby

# Load Configurations from file
PayPal::SDK::Core::Config.load('config/paypal.yml', 'development')

# Get Configurration
config = PayPal::SDK::Core::Config.config # Load default configuration
config = PayPal::SDK::Core::Config.config(:development) # Load specified environment configuration
config = PayPal::SDK::Core::Config.config(:development, :app_id => "XYZ") # Override configuration

# Create HTTP object
http      = PayPal::SDK::Core::HTTP.new
http      = PayPal::SDK::Core::HTTP.new(:development)
http      = PayPal::SDK::Core::HTTP.new("svcs.sandbox.paypal.com", 443)

# To make HTTP request.
response  = http.get("/AdaptivePayments/GetPaymentOptions")
```