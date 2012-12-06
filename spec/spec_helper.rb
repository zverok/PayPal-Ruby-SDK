require 'bundler/setup'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
end

Bundler.require :default, :test
PayPal::SDK::Core::Config.load('spec/config/paypal.yml', 'test')

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f }

RSpec.configure do |config|
  config.include SampleData
end
