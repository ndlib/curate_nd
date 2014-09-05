CurateNd::Application.routes.draw do
  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  root 'catalog#index'

  curate_for

  namespace :admin do
    constraints CurateND::AdminConstraint do
      get '/', to: 'base#index'

      mount Harbinger::Engine, at: 'harbinger'
      mount Resque::Server, :at => "queues"
      resources :announcements
      resources :accounts, only: [:show, :index] do
        collection { get :start_masquerading }
      end
    end
  end

  # Due to an apparent bug in devise the following routes should be presented
  # in this order
  scope :admin do
    constraints CurateND::AdminConstraint do
      devise_for :users, controllers: { masquerades: 'admin/masquerades'}, only: :masquerades
    end
  end

  delete 'dismiss_announcement/:id', to: 'admin/announcements#dismiss', as: 'dismiss_announcement'

  devise_scope :user do
    get 'dashboard', to: 'catalog#index', as: :user_root
    get 'admin/accounts/stop_masquerading', to: 'admin/masquerades#back', as: 'stop_masquerading'
  end
  devise_for :users, controllers: { sessions: :sessions, registrations: :registrations }, skip: :masquerades

  get 'about', to: 'static_pages#about'
  get 'beta',  to: 'static_pages#beta'
  get '502', to: 'static_pages#timeout_error'

end
