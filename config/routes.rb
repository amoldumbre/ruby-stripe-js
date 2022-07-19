Rails.application.routes.draw do
  resources :invoices
  resources :payments
  root 'invoices#index'
  get 'checkout/:invoice_id' => "payments#checkout", as: 'checkout'
  post '/create-payment-intent', to: "payments#create_payment_intent"
  get 'payment_status' => 'payments#status'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
