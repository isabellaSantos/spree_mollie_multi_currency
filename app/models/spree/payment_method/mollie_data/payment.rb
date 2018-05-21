module Spree
  class PaymentMethod
    module MollieData
      module Payment
        extend ActiveSupport::Concern

        def create_payment(order, mollie_method, redirect_url)
          amount = {
            currency: order.currency,
            value: order.total.to_s
          }
          description = "Order #{order.number}"
          response = mollie_client.prepare_payment(amount, description, redirect_url, order_metadata(order), mollie_method)
          status_object = StatusObject.new(response)

          if status_object.open?
            payment = order.payments.build(
              payment_method_id: id,
              amount: order.total,
              state: 'checkout',
              response_code: status_object.transaction_id
            )

            unless payment.save
              status_object.add_error(payment.errors.full_messages.join("\n"))
            end

            payment.pend!
          else
            if response['error'] && response['error']['message']
              status_object.add_error(response['error']['message'])
            elsif response['detail']
              status_object.add_error(response['detail'])
            else
              status_object.mollie_error = true
            end
          end
          status_object
        end

        def order_metadata(order)
          params = {
            order_id: order.number,
            line_items: [],
            adjustments: []
          }
          order.line_items.each_with_index do |li, index|
            params[:line_items] << { "item_#{index + 1}" => "#{li.quantity}x #{li.sku} : #{li.price}" }
          end
          params[:adjustments] << { "#1" => "Shipment total: #{order.shipment_total}" }
          order.all_adjustments.eligible.each_with_index do |adj, index|
            params[:adjustments] << { "##{index + 2}" => "#{adj.label}: #{adj.amount}" }
          end
          params
        end

        def update_payment_status(response_code)
          response = payment_status_in_mollie(response_code)
          payment = Spree::Payment.find_by(response_code: response['id'])

          unless payment.completed? || payment.failed?
            case response['status']
            when 'cancelled', 'expired'
              payment.failure! unless payment.failed?
            when 'pending'
              payment.pend! unless payment.pending?
            when 'paid', 'paidout'
              payment.complete! unless payment.completed?
              unless payment.order.complete?
                payment.order.next!
                if payment.order.state == 'payment'
                  payment.order.next!
                end
              end
            end
          end if payment
        end

        def payment_status_in_mollie(response_code)
          mollie_client.payment_status(response_code)
        end
      end
    end
  end
end
