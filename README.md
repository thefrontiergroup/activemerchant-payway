# ECI VALUES
* *CCT*  Call Centre Transaction
* *IVR* IVR Transaction
* *MTO* MOTO Transaction
* *SSL* Channel Encrypted Transaction (SSL or other)
* *1* 3D Secure transaction. This is the value returned from your MPI (Merchant Plugin Interface) software for 3D Secure transactions

# Usage

    gateway = ActiveMerchant::Billing::PayWayGateway.new(
      :username   => 'abcdefgh',
      :password   => '12345678',
      :pem        => '/location/of/certificate.pem',
      :eci        => 'SSL'
    )
    
    card = ActiveMerchant::Billing::CreditCard.new(
      :number     => 1234123412341234,
      :month      => 05,
      :year       => 2010,
      :first_name => 'Joe',
      :last_name  => 'Bloggs',
      :verification_value => 123,
      :type       => 'visa'
    )
    
    options = {
      :order_number => 'abc',
      :original_order_number => 'xyz' # used to call on past authentications
    }
    
    gateway.purchase(amount, card, options)