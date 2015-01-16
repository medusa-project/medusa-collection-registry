MedusaRails3::Application.routes.draw do

  resources :static_pages, only: [:show, :edit, :update], param: :key

  #This lets us start up in a mode where only a down page is shown
  if ENV['MEDUSA_DOWN'] == 'true'
    match '*path' => redirect('/static_pages/down', status: 307), via: :all
    root to: 'static_pages#show', key: 'down'
  else
    root to: 'static_pages#show', key: 'landing'
  end

  resources :collections do
    member do
      get 'red_flags'
      get 'events'
      get 'public'
      get 'assessments'
      get 'attachments'
    end
  end
  resources :repositories do
    collection do
      get 'edit_ldap_admins'
    end
    member do
      get 'red_flags'
      get 'events'
      get 'assessments'
      put 'update_ldap_admin'
      get 'collections'
    end
  end
  resources :institutions
  resources :assessments, only: [:show, :edit, :update, :new, :create, :destroy]
  resources :attachments, only: [:show, :edit, :update, :new, :create, :destroy] do
    member do
      get 'download'
    end
  end
  resources :events do
    collection do
      get :autocomplete_user_email
    end
  end

  [:file_groups, :external_file_groups, :bit_level_file_groups, :object_level_file_groups].each do |file_group_type|
    resources file_group_type, only: [:show, :edit, :update, :new, :create, :destroy] do
      member do
        post 'create_cfs_fits'
        get 'events'
        get 'red_flags'
        get 'public'
        get 'assessments'
        get 'attachments'
        post 'create_virus_scan'
        post 'create_amazon_backup'
        post 'create_initial_cfs_assessment' if file_group_type == :bit_level_file_groups
        post 'ingest' if file_group_type == :external_file_groups
      end
      collection do
        post 'bulk_amazon_backup'
      end
    end
  end

  resources :red_flags, only: [:show, :edit, :update] do
    member do
      post 'unflag'
    end
  end

  resources :producers
  resources :access_systems do
    member do
      get 'collections'
    end
  end
  resources :package_profiles do
    member do
      get 'collections'
    end
  end
  resources :directories, only: :show
  resources :files, only: :show, controller: "bit_files" do
    member do
      get 'contents'
      get 'view_fits_xml'
      get 'create_fits_xml'
    end
  end
  resources :virus_scans, only: :show
  resources :scheduled_events, only: [:edit, :update, :create, :destroy] do
    member do
      post 'complete'
      post 'cancel'
    end
  end

  resources :cfs_files, only: :show do
    member do
      get 'public'
      get 'public_download'
      get 'public_view'
      get 'create_fits_xml'
      get 'fits'
      get 'download'
      get 'view'
      get 'preview_image'
      get 'public_preview_image'
      get 'preview_video'
    end
  end
  resources :cfs_directories, only: :show do
    member do
      post 'create_fits_for_tree'
      post 'export'
      post 'export_tree'
      get 'public'
    end
  end

  resources :searches, only: [] do
    collection do
      post :filename
    end
  end

  resources :uuids, only: [:show]

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/login', to: 'sessions#new', as: :login, via: [:get, :post]
  match '/logout', to: 'sessions#destroy', as: :logout, via: [:get, :post]
  match '/unauthorized', to: 'sessions#unauthorized', as: :unauthorized, via: [:get, :post]
  match '/unauthorized_net_id', to: 'sessions#unauthorized_net_id', as: :unauthorized_net_id, via: [:get, :post]
  match '/dashboard', to: 'dashboard#show', as: :dashboard, via: [:get, :post]

  namespace :book_tracker do
    match 'items', to: 'items#index', as: :items, via: [:get, :post]
    match 'items/:id', to: 'items#show', as: :item, via: :get
    resources 'tasks', only: 'index'

    match 'check-google', to: 'tasks#check_google', via: 'post',
          as: 'check_google'
    match 'check-hathitrust', to: 'tasks#check_hathitrust', via: 'post',
          as: 'check_hathitrust'
    match 'check-internet-archive', to: 'tasks#check_internet_archive',
          via: 'post', as: 'check_internet_archive'
    match 'import', to: 'tasks#import', via: 'post'
  end

end
