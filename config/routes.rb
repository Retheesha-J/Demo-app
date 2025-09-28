Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]
  as :user do
    # only allow editing/updating current user (no new registration)
    get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
    put 'users' => 'devise/registrations#update', as: 'user_registration'
  end
  resources :users do
    post :send_email, on: :member
    post :send_bulk_emails, on: :collection
    member do
      post :upload_document
    end
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
  resources :documents do
    member do
      get :download
    end
  end

end 
