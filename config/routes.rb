Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]
  resources :users do
    post :send_email, on: :member
    post :send_bulk_emails, on: :collection
  end

  get "dashboard", to:"users#dashboard"
  devise_scope :user do
    authenticated :user do
      root to: "users#dashboard", as: :authenticated_root
    end

    unauthenticated do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

end
