module Spree
  class PaymentMethod::MollieMethod < Spree::PaymentMethod
    include MollieData::Payment

    preference :api_key, :string

    def source_required?
      false
    end

    def void(response_code, _gateway_options)
      begin
        payment = Spree::Payment.find_by(response_code: response_code)
        response = RestClient.post("https://api.mollie.com/v2/payments/#{response_code}/refunds",
                                    { amount: { value: payment.amount.to_s, currency: payment.order.currency } },
                                    { 'Authorization' => "Bearer #{preferred_api_key}" })
        return ActiveMerchant::Billing::Response.new(true, 'refunded', {}, authorization: response_code)
      rescue => error
        return ActiveMerchant::Billing::Response.new(false, error, {}, {})
      end
    end

    def cancel(response_code)
      void(response_code, {})
    end

    def mollie_client
      @client ||= begin
        ::MollieApi::Client.new(preferred_api_key, 'v2')
      end
    end

    def mollie_methods
      methods = mollie_client.payment_methods
      if methods['_embedded'] && methods['_embedded']['methods']
        methods['_embedded']['methods']
      else
        []
      end
    end

  end
end
