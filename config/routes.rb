CurateNd::Application.routes.draw do
  mount_roboto
  mount Orcid::Engine => "/orcid"
  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  root 'static_pages#home'

  # Making deposit a top-level route
  get '/classify_concerns/new', to: redirect('deposit')

  # Some ETDs are not loading correctly on the curation concern page
  ['etds', 'articles', 'datasets', 'senior_theses', 'images', 'patents', 'generic_files', 'finding_aids', 'documents', 'osf_archive'].each do |curation_concern|
    get "/concern/#{curation_concern}/new", to: "curation_concern/#{curation_concern}#new"
    get "/concern/#{curation_concern}/:id", to: redirect { |params, request|
      "/show/#{params[:id]}"
    }
  end
  scope module: 'curate' do
    resources 'collections', 'profiles', 'profile_sections', controller: 'collections' do
      collection do
        get :add_member_form
        put :add_member
        put :remove_member
      end
    end
    resources 'people', only: [:show, :index] do
      resources :depositors, only: [:index, :create, :destroy]
    end
    match 'profile' => 'user_profiles#show', via: :get, as: 'user_profile'
  end
  #resources :downloads, only: [:show]

  match 'collections' => 'collections#index', via: :get, as: 'curation_concern_collections'
  get 'collection/:id', to: redirect('collections/%{id}')
  match 'collections/:id' => 'collections#show', via: :get, as: 'curation_concern_collection'
  match 'collections/:id/edit' => 'collections#edit', via: :get, as: 'edit_curation_concern_collection'
  match 'people/:id' => 'people#show', via: :get, as: 'curation_concern_person'
  match 'people' => 'people#index', via: :get, as: 'curation_concern_people'

  namespace :curation_concern, path: :concern do
    Curate.configuration.registered_curation_concern_types.map(&:tableize).each do |container|
      resources container, except: [:index]
    end
    resources( :permissions, only:[]) do
      member do
        get :confirm
        post :copy
      end
    end
    resources( :linked_resources, only: [:new, :create], path: 'container/:parent_id/linked_resources')
    resources( :linked_resources, only: [:show, :edit, :update, :destroy])
    resources( :generic_files, only: [:new, :create], path: 'container/:parent_id/generic_files')
    resources( :generic_files, only: [:show, :edit, :update, :destroy]) do
      member do
        get :versions
        put :rollback
      end
    end
  end

  resources :terms_of_service_agreements, only: [:new, :create]
  resources :help_requests, only: [:new, :create]
  resources :classify_concerns, only: [:new, :create]
  resources :etd_vocabularies

  match "etd_vocabularies/type/:type" => "etd_vocabularies#index", via: :get, as: "etd_vocabularies_by_type"
  match "show/:id" => "common_objects#show", via: :get, as: "common_object"
  match "show/stub/:id" => "common_objects#show_stub_information", via: :get, as: "common_object_stub_information"
  match 'users/:id/edit' => 'users#edit', via: :get, as: 'edit_user'
  match 'downloads/:id(/:datastream_id)(.:format)' => 'downloads#show', via: :get, as: 'download'
  match 'catalog/hierarchy/admin_unit_hierarchy_sim/facet' => 'catalog#departments', via: :get, id: 'admin_unit_hierarchy_sim'
  match 'catalog/hierarchy/:id/facet' => 'catalog#hierarchy_facet', via: :get, as: 'catalog_hierarchy_facet'
  match 'departments' => 'catalog#departments', via: :get, as: 'departments', id: 'admin_unit_hierarchy_sim'

  scope module: 'bendo' do
    match 'cache_status' => 'file_cache_status#check', via: :get, as: 'bendo_cache_status'
    match 'recall/:id' => 'refresh_cache#recall_item', via: :get, as: 'recall_bendo_item'
    match 'refresh_cache/:id' => 'refresh_cache#request_item', via: :post, as: 'request_bendo_cache_refresh'
  end

  #scope module: 'hydramata' do
  namespace :hydramata do
    resources 'groups'
  end

  namespace :admin do
    constraints CurateND::AdminConstraint do
      get '/', to: 'base#index'

      mount Resque::Server, :at => "queues"
      resources :announcements
      resources :accounts, only: [:show, :index] do
        collection { get :start_masquerading }
        member { delete :disconnect_orcid_profile}
      end

      resource :repo_manager, only: [:edit, :update], path: :privledges
      resources :ingest_osf_archives #, only: [:new, :create, :index, :edit, :update]
      resources :batch_ingest, only: [:index]
    end

    constraints CurateND::AdminAPIConstraint do
      post "reindex", to: "reindex#reindex"
      post "add_to_collection", to: "add_to_collection#submit"
    end

    constraints CurateND::AdminAccessTokenConstraint do
      resources :temporary_access_tokens, path: 'access_tokens'
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

  devise_for :users, controllers: { sessions: :sessions, registrations: :registrations, omniauth_callbacks: 'devise/multi_auth/omniauth_callbacks' }, skip: :masquerades

  get '/show/citation/:id', to: 'citation#show', as: 'citation'

  get 'get_started', to: redirect('deposit')
  get 'deposit', to: 'classify_concerns#new'

  get 'about', to: 'static_pages#about'
  get 'beta',  to: redirect('/')
  get 'contribute', to: 'static_pages#contribute'
  get 'faqs',  to: 'static_pages#faqs'
  get 'orcid_settings', to: 'user_profiles#orcid_settings'
  get 'policies', to: 'static_pages#policies'
  get 'policies/:policyname', to: 'static_pages#policies', as: :named_policy
  get '500', to: 'static_pages#error'
  get '502', to: 'static_pages#error', default: { status_code: '502' }
  get '404', to: 'static_pages#error', default: { status_code: '404' }
  get '422', to: 'static_pages#error', default: { status_code: '422' }
  get '413', to: 'static_pages#error', default: { status_code: '413' }

end
