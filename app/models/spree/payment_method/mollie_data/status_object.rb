module Spree
  class PaymentMethod
    module MollieData
      class StatusObject
        attr_reader :transaction_id, :redirect_url, :errors, :payment_url, :response_status

        def initialize(response={})
          @response_status = response['status']
          @transaction_id = response['id']
          @redirect_url = response['redirectUrl']
          @payment_url = response['_links']['checkout']['href'] if response['_links'] && response['_links']['checkout']
          @mollie_error = false
          @errors = []
        end

        def open?
          @response_status == 'open'
        end

        def refunded?
          @response_status == 'refunded'
        end

        def has_error?
          !@errors.empty?
        end

        def mollie_error=(val)
          @mollie_error = val
        end

        def mollie_error?
          @mollie_error
        end

        def add_error(error = '')
          @errors << error
          self
        end
      end
    end
  end
end
