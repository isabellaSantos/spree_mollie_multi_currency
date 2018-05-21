Spree::Core::Engine.routes.draw do
  post '/mollie_payments/notify', to: 'mollie_payments#notify', as: 'notify_mollie_payment'
  get 'mollie_payments/check_status/:order_id', to: 'mollie_payments#check_payment_status', as: 'mollie_payment_check_status'
  get 'mollie_payments/get_payment/:transaction_id', to: 'mollie_payments#get_payment', as: 'mollie_payment_get_payment', defaults: { format: :js }
end
