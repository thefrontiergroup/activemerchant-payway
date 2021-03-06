require 'test/test_helper'
require 'active_merchant/billing/gateways/pay_way'

class PayWayTest < Test::Unit::TestCase
  
  def setup
    @gateway = ActiveMerchant::Billing::PayWayGateway.new(
      :username => '12341234',
      :password => 'abcdabcd',
      :pem      => 'config/payway.pem'
    )
    
    @amount = 1000
    
    @credit_card = ActiveMerchant::Billing::CreditCard.new(
      :number             => 4564710000000004,
      :month              => 2,
      :year               => 2019,
      :first_name         => 'Bob',
      :last_name          => 'Smith',
      :verification_value => '847',
      :type               => 'visa'
    )
    
    @options = {
      :order_number         => 'abc',
      :orginal_order_number => 'xyz'
    }
  end
  
  def test_successful_purchase_visa
    @gateway.stubs(:ssl_post).returns(successful_response_visa)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_success response
    
    assert_match '0',     response.params['summary_code']
    assert_match '08',    response.params['response_code']
    assert_match 'VISA',  response.params['card_scheme_name']
  end
  
  def test_successful_purchase_master_card
    @gateway.stubs(:ssl_post).returns(successful_response_master_card)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_success response
    
    assert_match '0',           response.params['summary_code']
    assert_match '08',          response.params['response_code']
    assert_match 'MASTERCARD',  response.params['card_scheme_name']
  end
  
  def test_successful_authorize_visa
    @gateway.stubs(:ssl_post).returns(successful_response_visa)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_success response
    
    assert_match '0',     response.params['summary_code']
    assert_match '08',    response.params['response_code']
    assert_match 'VISA',  response.params['card_scheme_name']
  end
  
  def test_successful_authorize_master_card
    @gateway.stubs(:ssl_post).returns(successful_response_master_card)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_success response
    
    assert_match '0',           response.params['summary_code']
    assert_match '08',          response.params['response_code']
    assert_match 'MASTERCARD',  response.params['card_scheme_name']
  end
  
  def test_successful_capture_visa
    @gateway.stubs(:ssl_post).returns(successful_response_visa)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_success response
    
    assert_match '0',     response.params['summary_code']
    assert_match '08',    response.params['response_code']
    assert_match 'VISA',  response.params['card_scheme_name']
  end
  
  def test_successful_capture_master_card
    @gateway.stubs(:ssl_post).returns(successful_response_master_card)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_success response
    
    assert_match '0',           response.params['summary_code']
    assert_match '08',          response.params['response_code']
    assert_match 'MASTERCARD',  response.params['card_scheme_name']
  end
  
  def test_successful_credit_visa
    @gateway.stubs(:ssl_post).returns(successful_response_visa)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_success response
    
    assert_match '0',     response.params['summary_code']
    assert_match '08',    response.params['response_code']
    assert_match 'VISA',  response.params['card_scheme_name']
  end
  
  def test_successful_credit_master_card
    @gateway.stubs(:ssl_post).returns(successful_response_master_card)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_success response
    
    assert_match '0',           response.params['summary_code']
    assert_match '08',          response.params['response_code']
    assert_match 'MASTERCARD',  response.params['card_scheme_name']
  end

  def test_purchase_with_invalid_credit_card
    @gateway.stubs(:ssl_post).returns(purchase_with_invalid_credit_card_response)
    
    credit_card.number = 4444333322221111
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_failure response
    
    assert_match '1',   response.params['summary_code']
    assert_match '14',  response.params['response_code']
  end

  def test_purchase_with_expired_credit_card
    @gateway.stubs(:ssl_post).returns(purchase_with_expired_credit_card_response)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_failure response
    
    assert_match '1',   response.params['summary_code']
    assert_match '54',  response.params['response_code']
  end

  def test_purchase_with_invalid_month
    @gateway.stubs(:ssl_post).returns(purchase_with_invalid_month_response)
    @credit_card.month = 13  
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_failure response
    
    assert_match '3',   response.params['summary_code']
    assert_match 'QA',  response.params['response_code']
  end

  def test_bad_login
    @gateway.stubs(:ssl_post).returns(bad_login_response)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_failure response
    
    assert_match '3',   response.params['summary_code']
    assert_match 'QH',  response.params['response_code']
  end

  def test_bad_merchant
    @gateway.stubs(:ssl_post).returns(bad_merchant_response)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
    
    assert_instance_of Response, response
    assert_failure response
    
    assert_match '3',   response.params['summary_code']
    assert_match 'QK',  response.params['response_code']
  end

  private
  
    def successful_response_visa
      "response.summaryCode=0&response.responseCode=08&response.cardSchemeName=VISA"
    end
    
    def successful_response_master_card
      "response.summaryCode=0&response.responseCode=08&response.cardSchemeName=MASTERCARD"
    end
    
    def purchase_with_invalid_credit_card_response
      "response.summaryCode=1&response.responseCode=14"
    end
    
    def purchase_with_expired_credit_card_response
      "response.summaryCode=1&response.responseCode=54"
    end 
    
    def purchase_with_invalid_month_response
      "response.summaryCode=3&response.responseCode=QA"
    end
    
    def bad_login_response
      "response.summaryCode=3&response.responseCode=QH"
    end
    
    def bad_merchant_response
      "response.summaryCode=3&response.responseCode=QK"
    end
end