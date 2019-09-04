CurateNd::Application.routes.draw do
  mount_roboto
  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  root 'static_pages#home'

  # Making deposit a top-level route
  get '/classify_concerns/new', to: redirect('deposit')

  # Some ETDs are not loading correctly on the curation concern page
  ['etds', 'articles', 'audios', 'datasets', 'senior_theses', 'images', 'patents', 'generic_files', 'finding_aids', 'documents', 'catholic_documents', 'osf_archives', 'videos'].each do |curation_concern|
    get "/concern/#{curation_concern}/new", to: "curation_concern/#{curation_concern}#new"
    get "/concern/#{curation_concern}/:id", to: redirect { |params, request|
      "/show/#{params[:id]}"
    }
  end
  scope module: 'curate' do
    resources 'collections', 'profiles', 'profile_sections', controller: 'collections', except: [:destroy] do
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

  scope module: 'orcid', path: 'orcid' do
    resource :profile_request, only: [:show, :new, :create, :destroy]
    resources :profile_connections, only: [:new, :create, :index]

    get 'create_orcid', to: 'create_profile#create'
    get "disconnect", to: "profile_connections#destroy"
  end

  match 'collections' => 'collections#index', via: :get, as: 'curation_concern_collections'
  get 'collection/:id', to: redirect('collections/%{id}')
  match 'collections/:id' => 'collections#show', via: :get, as: 'curation_concern_collection'
  match 'collections/:id/edit' => 'collections#edit', via: :get, as: 'edit_curation_concern_collection'
  match 'people/:id' => 'people#show', via: :get, as: 'curation_concern_person'
  match 'people' => 'people#index', via: :get, as: 'curation_concern_people'

  namespace :curation_concern, path: :concern do
    Curate.configuration.registered_curation_concern_types.map(&:tableize).each do |container|
      resources container, except: [:index, :destroy]
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
    resources( :generic_files, only: [:show, :edit, :update]) do
      member do
        get :versions
        put :rollback
      end
    end
  end

  resources :terms_of_service_agreements, only: [:new, :create]
  resources :help_requests, only: [:new, :create]
  resources :classify_concerns, only: [:new, :create]

  get '/image_viewer/:id', controller: 'common_objects', action: 'original_viewer'
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
      resources :ingest_osf_archives, only: [:new, :create]
      resources :batch_ingest, only: [:index]
      resources :fixity, only: [:index]
    end

    constraints CurateND::AdminAPIConstraint do
      post "reindex", to: "reindex#reindex"
      post "add_to_collection", to: "add_to_collection#submit"
      post "assign_group", to: "batch_edit#assign_group"
    end

    match 'reindex/:id' => 'reindex#reindex_pid', via: :get, as: 'reindex_pid'
  end

  namespace :api do
    get 'items/download/:id', as: 'item_download', controller: 'downloads', action: 'download'
    resources :items, only: [:show, :index]
    resources :access_tokens, only: [:new, :index, :create, :destroy]
    get 'uploads/new', as: 'trx_initiate', controller: 'uploads', action: 'trx_initiate'
    post 'uploads/:tid/file/new', as: 'trx_new_file', controller: 'uploads', action: 'trx_new_file'
    post 'uploads/:tid/file/:fid', as: 'trx_append', controller: 'uploads', action: 'trx_append'
    get 'uploads/:tid/status', controller: 'uploads', action: 'trx_status'
    post 'uploads/:tid/commit', as: 'trx_commit', controller: 'uploads', action: 'trx_commit'
  end
  # manage ingest callbacks: batch ingest responds with a post
  post 'uploads/:tid/callback/:response', controller: 'admin/callbacks', action: 'callback_response'

  # clean up tokens
  resources :temporary_access_tokens, path: 'access_tokens', except: [:show]
  post 'temporary_access_tokens/remove_expired_tokens', as: 'remove_expired_tokens', controller: 'temporary_access_tokens', action: 'remove_expired_tokens'
  post 'temporary_access_tokens/revoke_access', as: 'revoke_token_access', controller: 'temporary_access_tokens', action: 'revoke_token_access'
  get 'temporary_access_tokens/remove_expired_tokens', controller: 'temporary_access_tokens', action: 'remove_expired_tokens'

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
  get 'faq',  to: redirect('/faqs')
  get 'orcid_settings', to: 'user_profiles#orcid_settings'
  get 'policies', to: 'static_pages#policies'
  get 'policies/:policyname', to: 'static_pages#policies', as: :named_policy
  get '500', to: 'static_pages#error'
  get '502', to: 'static_pages#error', default: { status_code: '502' }
  get '404', to: 'static_pages#error', default: { status_code: '404' }
  get '422', to: 'static_pages#error', default: { status_code: '422' }
  get '413', to: 'static_pages#error', default: { status_code: '413' }

  get '/s/:slug', to: redirect('http://link.library.nd.edu/%{slug}', status: 302)
end
