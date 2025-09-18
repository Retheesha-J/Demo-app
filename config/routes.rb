Rails.application.routes.draw do
  resources :users do
    post :send_email, on: :member
    post :send_bulk_emails, on: :collection
  end
  root "users#login"
  get "login",to:"users#login"
  post "login", to:"users#login_create"
  get "dashboard", to:"users#dashboard"
  delete "logout", to:"users#logout"

end
