module Spree
  class MolliePaymentsController < BaseController
    layout false
    respond_to :html, :js

    protect_from_forgery except: [:notify]

    def notify
      MolliePaymentService.new(payment_id: params[:id]).update_payment_status

      render nothing: true, status: :ok
    end

    def check_payment_status
      order = Spree::Order.friendly.find params[:order_id]
      mollie_payment = order.payments.last

      paid_before = order.paid?
      mollie_payment.payment_method.update_payment_status(mollie_payment.response_code)
      order = order.reload

      flash['order_completed'] = true if !paid_before && order.paid?

      redirect_to order.paid? ? order_path(order) : checkout_state_path(:payment)
    end

  end
end
