CurateNd::Application.routes.draw do
  mount_roboto

  Blacklight.add_routes(self)
  # HydraHead.add_routes(self)
  # Hydra::BatchEdit.add_routes(self)

  devise_for :users

  resources 'dashboard', :only=>:index do
    collection do
      get 'page/:page', :action => :index
      get 'facet/:id',  :action => :facet, :as => :dashboard_facet
      get 'related/:id',:action => :get_related_file, :as => :related_file
    end
  end
  resources :downloads, only: [:show]

  namespace :curation_concern, path: :concern do
    resources :senior_theses, except: :index
    resources(
      :generic_files,
      only: [:new, :create],
      path: 'container/:parent_id/generic_files'
    )
    resources(
      :generic_files,
      only: [:show, :edit, :update, :destroy]
    )
  end

  resources :terms_of_service_agreements, only: [:new, :create]
  resources :help_requests, only: [:new, :create]
  resources :classify_concerns, only: [:new, :create]

  match "show/:id" => "common_objects#show", via: :get, as: "common_object"
  match "show/stub/:id" => "common_objects#show_stub_information", via: :get, as: "common_object_stub_information"
  root to: 'welcome#index'
end
