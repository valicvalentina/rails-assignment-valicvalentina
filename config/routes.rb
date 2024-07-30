Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
    namespace :api do
      resources :users do
        member do
          put 'change_password'
        end
      end
      resources :companies
      resources :flights
      resources :bookings
      resource :session
    end
end
