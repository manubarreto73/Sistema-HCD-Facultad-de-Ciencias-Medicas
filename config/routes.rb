Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
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
