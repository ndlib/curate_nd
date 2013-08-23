CurateNd::Application.routes.draw do
  devise_for :users
  devise_scope :users do
    get 'dashboard', to: 'dashboard#index', as: :user_root
  end

  namespace :curation_concern, path: :concern do
    resources :senior_theses, except: :index
  end

  resources :users, only: [:update, :show, :edit]

  namespace :admin do
    constraints CurateND::AdminConstraint do
      mount Resque::Server, :at => "queues"
    end
  end

end
