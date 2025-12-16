Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: "users/passwords"
  }

  resource :password_change,
           controller: "password_changes",
           only: [:edit, :update]

  get "up" => "rails/health#show", as: :rails_health_check

  root "daily_agendas#today"

  resources :subjects do
    member do
      get :modal_delete
    end
  end
  resources :destinations do
    member do
      get :modal_delete
    end
  end

  resources :expedients do
    member do
      put :treat_from_agenda
      put :delete_from_agenda
      get :mark_as_treated_modal
      get :modal_delete
      get :history
    end
    collection do
      get :download_pdf
    end
  end

  resources :daily_agendas do
    member do
      get :add_expedients
      post :attach_expedient
      put :resolve
      get :download_pdf
      put :mark_expedient_as_treated
      get :mark_as_treated_modal
    end
    collection do
      get :modal_list
      get :today
    end
  end
end
