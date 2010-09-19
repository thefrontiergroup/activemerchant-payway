require 'test/test_helper'
require 'active_merchant/billing/gateways/pay_way'

USERNAME = File.new('config/credentials.txt').readlines[0].gsub("\n",""))
PASSWORD = File.new('config/credentials.txt').readlines[1].gsub("\n",""))
PEM_FILE = 'config/payway.pem'

class RemotePayWayTest < Test::Unit::TestCase
  
  def setup
    @amount   = 1000
    
    @options  = {
      :order_number           => 'abc',
      :original_order_number  => 'xyz'
    }
    
    @gateway = ActiveMerchant::Billing::PayWayGateway.new(
      :username => USERNAME, 
      :password => PASSWORD, 
      :merchant => 'TEST', 
      :pem      => PEM_FILE
    )
    
    @visa = ActiveMerchant::Billing::CreditCard.new(
      :number             => 4564710000000004,
      :month              => 2,
      :year               => 2019,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => 847,
      :type               => 'visa'
    )
    
    @mastercard = ActiveMerchant::Billing::CreditCard.new(
      :number             => 5163200000000008,
      :month              => 8,
      :year               => 2020,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => 070,
      :type               => 'master'
    )
    
    @amex = ActiveMerchant::Billing::CreditCard.new(
      :number             => 376000000000006,
      :month              => 6,
      :year               => 2020,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => 2349,
      :type               => 'american_express'
    )
    
    @diners = ActiveMerchant::Billing::CreditCard.new(
      :number             => 36430000000007,
      :month              => 6,
      :year               => 2022,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => 348,
      :type               => 'diners_club'
    )
    
    @expired = ActiveMerchant::Billing::CreditCard.new(
      :number             => 4564710000000012,
      :month              => 2,
      :year               => 2005,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => 963,
      :type               => 'visa'
    )
    
    @low = ActiveMerchant::Billing::CreditCard.new(
      :number             => 4564710000000020,
      :month              => 5,
      :year               => 2020,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => 234,
      :type               => 'visa'
    )
    
    @stolen = ActiveMerchant::Billing::CreditCard.new(
      :number             => 5163200000000016,
      :month              => 12,
      :year               => 2019,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => 728,
      :type               => 'master'
    )
    
    @invalid = ActiveMerchant::Billing::CreditCard.new(
      :number             => 4564720000000037,
      :month              => 9,
      :year               => 2019,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => 030,
      :type               => 'visa'
    )
    
    @restricted = ActiveMerchant::Billing::CreditCard.new(
      :number             => 343400000000016,
      :month              => 1,
      :year               => 2019,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => 9023,
      :type               => 'american_express'
    )
    
    @stolen = ActiveMerchant::Billing::CreditCard.new(
      :number             => 36430000000015,
      :month              => 8,
      :year               => 2021,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => 988,
      :type               => 'diners_club'
    )
  end
  
  def test_successful_visa
    assert response = @gateway.purchase(@amount, @visa, @options)
    assert_success response
    assert_equal 'Approved - Completed Successfully', response.message
  end
  
  def test_successful_mastercard
    assert response = @gateway.purchase(@amount, @mastercard, @options)
    assert_failure response
    assert_equal 'Approved - Completed Successfully', response.message
  end
  
  def test_successful_amex
    assert response = @gateway.purchase(@amount, @amex, @options)
    assert_failure response
    assert_equal 'Approved - Completed Successfully', response.message
  end
  
  def test_successful_diners
    assert response = @gateway.purchase(@amount, @diners, @options)
    assert_failure response
    assert_equal 'Approved - Completed Successfully', response.message
  end
  
  def test_expired_visa
    assert response = @gateway.purchase(@amount, @expired, @options)
    assert_failure response
    assert_equal 'Rejected - Expired card', response.message
  end
  
  def test_low_visa
    assert response = @gateway.purchase(@amount, @low, @options)
    assert_failure response
    assert_equal 'Rejected - Not sufficient funds', response.message
  end
  
  def test_stolen_mastercard
    assert response = @gateway.purchase(@amount, @stolen, @options)
    assert_failure response
    assert_equal 'Rejected - Stolen card', response.message
  end
  
  def test_invalid_visa
    assert response = @gateway.purchase(@amount, @stolen, @options)
    assert_failure response
    assert_equal 'Rejected - Invalid Credit Card Verification Number', response.message
  end
  
  def test_restricted_amex
    assert response = @gateway.purchase(@amount, @restricted, @options)
    assert_failure response
    assert_equal 'Rejected - Restricted card', response.message
  end
  
  def test_stolen_diners
    assert response = @gateway.purchase(@amount, @stolen, @options)
    assert_failure response
    assert_equal 'Rejected - Stolen card', response.message
  end
  
  def test_invalid_login
    gateway = ActiveMerchant::Billing::PayWayGateway.new(
      :username => '',
      :password => '',
      :merchant => 'TEST',
      :pem      => './payway.pem'
    )
    
    puts response.inspect
    
    assert response = gateway.purchase(@amount, @visa, @options)
    assert_failure response
    assert_equal 'Erred - Invalid merchant', response.message
  end
  
end