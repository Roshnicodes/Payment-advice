Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "login" => "sessions#new", as: :login
  post "login" => "sessions#create"
  delete "logout" => "sessions#destroy", as: :logout

  get "payment-advice" => "payment_advices#new", as: :payment_advice
  resources :payment_advices, only: :create do
    post :send_mail, on: :member
  end
  delete "payment_advices/:id" => "payment_advices#destroy", as: :payment_advice_record
  resources :banks, only: %i[create destroy]

  namespace :api do
    namespace :v1 do
      post "payment_advices/send_mail", to: "payment_advices#create_and_send"
    end
  end

  root "sessions#new"
end
