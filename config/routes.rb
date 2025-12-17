Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: "users/passwords",
    registrations: "users/registrations"
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
    collection do
      get :daily_agenda_index
    end
  end

  resources :expedients do
    member do
      put :treat_from_agenda
      put :delete_from_agenda
      get :delete_from_agenda_modal
      get :mark_as_treated_modal
      get :modal_delete
      get :history
    end
    collection do
      get :download_pdf
      get :deleted
    end
  end

  resources :daily_agendas, except: [:index] do
    member do
      get :add_expedients
      post :attach_expedient
      put :resolve
      get :download_pdf
      put :mark_expedient_as_treated
      get :mark_as_treated_modal
      get :today
      get :modal_list
      get :treated
      patch :treat_destination
      get  :edit_expedients
      patch :update_expedients_order
    end

    collection do
      get :today
    end
  end

  get 'destination_agenda/:destination_id',
      to: 'daily_agendas#today',
      as: :destination_daily_agenda
  get 'destination_agenda/:destination_id/treated',
      to: 'daily_agendas#treated',
      as: :destination_daily_agendas_treated
  get 'destination_agenda/:id/treat',
      to: 'daily_agendas#treat',
      as: :destination_daily_agendas_treat
end
