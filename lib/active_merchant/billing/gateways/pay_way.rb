module ActiveMerchant
  module Billing
      
    class PayWayGateway < Gateway

      URL           = 'https://ccapi.client.qvalent.com/payway/ccapi'
      
      SUMMARY_CODES = { 
                        '0' => 'Approved',
                        '1' => 'Declined',
                        '2' => 'Erred',
                        '3' => 'Rejected'
                      }
                      
      RESPONSE_CODES= {
                        '00' => 'Completed Successfully',
                        '01' => 'Refer to card issuer',
                        '03' => 'Invalid merchant',
                        '04' => 'Pick-up card',
                        '05' => 'Do not honour',
                        '08' => 'Honour only with identification',
                        '12' => 'Invalid transaction',
                        '13' => 'Invalid amount',
                        '14' => 'Invalid card number (no such number)',
                        '30' => 'Format error',
                        '36' => 'Restricted card',
                        '41' => 'Lost card',
                        '42' => 'No universal card',
                        '43' => 'Stolen card',
                        '51' => 'Not sufficient funds',
                        '54' => 'Expired card',
                        '61' => 'Exceeds withdrawal amount limits',
                        '62' => 'Restricted card',
                        '65' => 'Exceeds withdrawal frequency limit',
                        '91' => 'Issuer or switch is inoperative',
                        '92' => 'Financial institution or intermediate network facility cannot be found for routing',
                        '94' => 'Duplicate transmission',
                        'Q1' => 'Unknown Buyer',
                        'Q2' => 'Transaction Pending',
                        'Q3' => 'Payment Gateway Connection Error',
                        'Q4' => 'Payment Gateway Unavailable',
                        'Q5' => 'Invalid Transaction',
                        'Q6' => 'Duplicate Transaction – requery to determine status',
                        'QA' => 'Invalid parameters or Initialisation failed',
                        'QB' => 'Order type not currently supported',
                        'QC' => 'Invalid Order Type',
                        'QD' => 'Invalid Payment Amount - Payment amount less than minimum/exceeds maximum allowed limit',
                        'QE' => 'Internal Error',
                        'QF' => 'Transaction Failed',
                        'QG' => 'Unknown Customer Order Number',
                        'QH' => 'Unknown Customer Username or Password',
                        'QI' => 'Transaction incomplete - contact Westpac to confirm reconciliation',
                        'QJ' => 'Invalid Client Certificate',
                        'QK' => 'Unknown Customer Merchant',
                        'QL' => 'Business Group not configured for customer',
                        'QM' => 'Payment Instrument not configured for customer',
                        'QN' => 'Configuration Error',
                        'QO' => 'Missing Payment Instrument',
                        'QP' => 'Missing Supplier Account',
                        'QQ' => 'Invalid Credit Card Verification Number',
                        'QR' => 'Transaction Retry',
                        'QS' => 'Transaction Successful',
                        'QT' => 'Invalid currency',
                        'QU' => 'Unknown Customer IP Address',
                        'QV' => 'Invalid Original Order Number specified for Refund, Refund amount exceeds capture amount, or Previous capture was not approved',
                        'QW' => 'Invalid Reference Number',
                        'QX' => 'Network Error has occurred',
                        'QY' => 'Card Type Not Accepted',
                        'QZ' => 'Zero value transaction'
                      }
                      
      TRANSACTIONS  = {
                        :authorization  => 'preauth',
                        :purchase       => 'capture',
                        :capture        => 'captureWithoutAuth',
                        :status         => 'query',
                        :credit         => 'refund'
                      }
      
      self.supported_countries = [ 'AU' ]
      self.supported_cardtypes = [ :visa, :master, :diners_club, :american_express, :bankcard ]
      self.display_name        = 'Pay Way'
      self.homepage_url        = 'http://www.payway.com.au'
      self.default_currency    = 'AUD'
      self.money_format        = :cents
      
      # Create a new Payway gateway.
      def initialize(options = {})
        requires!(options, :username, :password, :pem)
        @options = options
        
        @options[:eci]      ||= 'SSL'
        @options[:currency] ||= default_currency
        @options[:merchant] ||= 'TEST'
        @options[:pem]        = File.read(options[:pem])
        
        @post = {}
        @transaction = {}
        
        super
      end
      
      # Build the string and send it
      def process(action, amount, credit_card)
        @transaction.merge!({
          :type         => action,
          :amount       => amount,
          :credit_card  => credit_card
        })
        
        build_card
        build_order
        build_customer
        
        send_post
      end
      
      def authorize(amount, credit_card, options = {})
        requires!(options, :order_number)
        
        @transaction.merge!({ :order_number => options[:order_number] })
        
        process(:authorize, amount, credit_card)
      end
      
      def capture(amount, credit_card, options = {})
        requires!(options, :order_number, :original_order_number)
        
        @transaction.merge!({ 
          :order_number           => options[:order_number],
          :original_order_number  => options[:original_order_number]
        })
        
        process(:capture, amount, credit_card)
      end
      
      def purchase(amount, credit_card, options = {})
        requires!(options, :order_number)
        
        @transaction.merge!({ :order_number => options[:order_number] })
        
        process(:purchase, amount, credit_card)
      end
      
      def credit(amount, credit_card, options = {})
        requires!(options, :order_number, :original_order_number)
        
        
        @transaction.merge!({ 
          :order_number           => options[:order_number],
          :original_order_number  => options[:original_order_number]
        })
        
        process(:credit, amount, credit_card)
      end
      
      def status(options = {})
        requires!(options, :order_number)
        @transaction = transaction
        @transaction[:type] = TRANSACTIONS[:status]
        
        build_order
        
        send_post
      end
      
      private
        
        # Adds credit card details to the post hash
        def build_card
          card = @transaction[:credit_card]
          @post.merge!({
            'card.cardHolderName' => "#{card.first_name} #{card.last_name}",
            'card.PAN'            => card.number,
            'card.CVN'            => card.verification_value,
            'card.expiryYear'     => card.year.to_s[-2,2],
            'card.expiryMonth'    => sprintf('%02d', card.month),
            'card.currency'       => @options[:currency]
          })
        end
        
        # Adds the order arguments to the post hash
        def build_order
          @post.merge!({
            'order.ECI'           => @options[:eci],
            'order.amount'        => @transaction[:amount],
            'order.type'          => TRANSACTIONS[@transaction[:type]]
          })
          
          if @transaction[:original_order_number].present?
            @post['order.originalOrderNumber'] = @transaction[:original_order_number]
          end
        end
        
        # Adds the customer arguments to the post hash
        def build_customer
          @post.merge!({
            'customer.username'   => @options[:username],
            'customer.password'   => @options[:password],
            'customer.merchant'   => @options[:merchant],
            'customer.orderNumber'=> "#{@transaction[:order_number]} - #{Time.new.to_i.to_s}",
          })
        end
        
        # Creates the request and returns the sumarised result
        def send_post
          @request = URI.encode(@post.map {|k,v| "#{k}=#{v}"}.join('&'))
          
          @response = ssl_post(URL, @request)
          
          result = process_response
        end
        
        def process_response
          params = {}
          
          @response.split("&").each do |items|
            key, value = items.split("=")
            key = key.split('.')[1]
            params[key.underscore.to_sym] = value
          end
          
          msg     = "#{SUMMARY_CODES[params[:summary_code]]} - #{RESPONSE_CODES[params[:response_code]]}"
          
          success = params[:summary_code].to_s == "0"
          options = { :test => @options[:merchant].to_s == "TEST" }
          
          result = Response.new(success, msg, params, options)
        end
    end
  end
end