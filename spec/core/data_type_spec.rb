require 'spec_helper'

describe PayPal::SDK::Core::API::DataTypes::Base do

  DataType = PayPal::SDK::Core::API::DataTypes::Base

  class TestCurrency < DataType

    # Members
    object_of :amount, String
    object_of :type,   String, :namespace => "ns"
    # Attributes
    add_attribute :code
  end

  class TestType < DataType
    object_of :fromCurrency, TestCurrency
    array_of  :toCurrency,   TestCurrency
  end

  it "should create member object automatically" do
    test_type = TestType.new
    test_type.fromCurrency.should   be_a TestCurrency
    test_type.toCurrency.should     be_a Array
    test_type.toCurrency[0].should  be_a TestCurrency
    test_type.toCurrency[1].should  be_a TestCurrency
    test_type.toCurrency[0].amount.should eql nil
    test_type.fromCurrency.amount.should  eql nil
    test_type.fromCurrency.type.should    eql nil
  end

  it "should convert the given data to configured type" do
    test_type = TestType.new( :fromCurrency => { :code => "USD", :amount => "50.0"})
    test_type.fromCurrency.should be_a TestCurrency
    test_type.fromCurrency.code.should    eql "USD"
    test_type.fromCurrency.amount.should  eql "50.0"
  end

  it "should allow block with initializer" do
    test_type = TestType.new do
      fromCurrency do
        self.code   = "USD"
        self.amount = "50.0"
      end
    end
    test_type.fromCurrency.code.should    eql "USD"
    test_type.fromCurrency.amount.should  eql "50.0"
  end

  it "should allow block with member" do
    test_type = TestType.new
    test_type.fromCurrency do
      self.code = "USD"
      self.amount = "50.0"
    end
    test_type.fromCurrency.code.should    eql "USD"
    test_type.fromCurrency.amount.should  eql "50.0"
  end

  it "should assign value to attribute" do
    test_currency = TestCurrency.new( :@code => "USD", :amount => "50" )
    test_currency.code.should eql "USD"
  end

  it "should allow configured Class object" do
    test_currency = TestCurrency.new( :code => "USD", :amount => "50" )
    test_type = TestType.new( :fromCurrency => test_currency )
    test_type.fromCurrency.should eql test_currency
  end

  it "should allow snakecase" do
    test_type = TestType.new( :from_currency => {} )
    test_type.from_currency.should be_a TestCurrency
    test_type.from_currency.should eql test_type.fromCurrency
  end

  it "should allow array" do
    test_type = TestType.new( :toCurrency => [{ :code => "USD", :amount => "50.0" }] )
    test_type.toCurrency.should be_a Array
    test_type.toCurrency.first.should be_a TestCurrency
  end

  it "should allow only configured fields" do
    lambda do
      TestType.new( :notExist => "testing")
    end.should raise_error
  end

  it "should not convert empty hash" do
    test_type = TestType.new( :fromCurrency => {} )
    test_type.to_hash.should eql({})
  end

  it "should not convert empty array" do
    test_type = TestType.new( :toCurrency => [] )
    test_type.to_hash.should eql({})
  end

  it "should not convert array of empty hash" do
    test_type = TestType.new( :toCurrency => [ {} ] )
    test_type.to_hash.should eql({})
  end

  it "should return empty hash" do
    test_type = TestType.new
    test_type.to_hash.should eql({})
  end

  it "should convert to hash" do
    test_currency = TestCurrency.new(:amount => "500")
    test_currency.to_hash.should eql(:amount => "500")
  end

  it "should convert to hash with key as string" do
    test_currency = TestCurrency.new(:amount => "500")
    test_currency.to_hash(:symbol => false).should eql("amount" => "500")
  end

  it "should convert attribute key with @" do
    test_currency = TestCurrency.new( :code => "USD", :amount => "50" )
    test_currency.to_hash[:@code].should eql "USD"
  end

  it "should convert attribute key without @" do
    test_currency = TestCurrency.new( :code => "USD", :amount => "50" )
    test_currency.to_hash(:attribute => false)[:code].should eql "USD"
  end


  it "should convert to hash with namespace" do
    test_currency = TestCurrency.new(:amount => "500", :type => "USD" )
    hash = test_currency.to_hash
    hash[:amount].should eql "500"
    hash[:"ns:type"].should eql "USD"
    hash = test_currency.to_hash(:namespace => false)
    hash[:amount].should eql "500"
    hash[:type].should eql "USD"
  end

  it "should allow namespace" do
    test_currency = TestCurrency.new(:amount => "500", :"ns:type" => "USD" )
    test_currency.type.should eql "USD"
  end

end

