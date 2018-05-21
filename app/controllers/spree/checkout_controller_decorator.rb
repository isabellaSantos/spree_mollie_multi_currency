module Spree
  CheckoutController.class_eval do
    before_action :load_mollie_payment_methods, only: [:edit]
    before_action :pay_with_mollie, only: [:update]

    protected

    def load_mollie_payment_methods
      return if params[:state] != 'payment' || @order.state != 'payment'

      mollie_payment = @order.available_payment_methods.find { |pm| pm.is_a?(Spree::PaymentMethod::MollieMethod) }
      if mollie_payment
        methods = get_mollie_payment_methods(mollie_payment)
        filter_mollie_payment_methods(methods)
      end
    end

    def get_mollie_payment_methods(mollie_payment)
      Rails.cache.fetch("mollie-payment-methods", expires_in: 15.minutes) do
        mollie_payment.mollie_methods
      end
    end

    def filter_mollie_payment_methods(methods)
      @mollie_payment_methods = methods
    end

    def pay_with_mollie
      return if params[:state] != 'payment'

      pm_id = params[:order][:payments_attributes].first[:payment_method_id]
      payment_method = Spree::PaymentMethod.find(pm_id)

      if payment_method && payment_method.is_a?(Spree::PaymentMethod::MollieMethod)
        mollie_method = params[:order][:payments_attributes].first[:mollie_method_id]
        status_object = payment_method.create_payment(@order, mollie_method, mollie_payment_check_status_url(@order.number))

        if status_object.mollie_error?
          mollie_error and return
        end

        if status_object.has_error?
          flash[:error] = status_object.errors.join("\n")
          redirect_to checkout_state_path(@order.state) and return
        end
        redirect_to status_object.payment_url
      end

      def mollie_error(e = nil)
        @order.errors[:base] << "Mollie error #{e.try(:message)}"
        render :edit
      end
    end
  end
end
