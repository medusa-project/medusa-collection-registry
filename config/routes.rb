MedusaRails3::Application.routes.draw do

  get "events/index"

  root :to => 'static#page', :page => 'landing'

  resources :collections do
    collection do
      get 'for_access_system'
      get 'for_package_profile'
    end
    member do
      get 'red_flags'
      get 'events'
    end
  end
  resources :repositories do
    collection do
      get 'edit_ldap_admins'
    end
    member do
      get 'red_flags'
      get 'events'
      put 'update_ldap_admin'
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
        post 'create_all_fits'
        post 'create_cfs_fits'
        get 'events'
        get 'red_flags'
        post 'create_virus_scan'
        post 'create_amazon_backup'
        post 'create_initial_cfs_assessment' if file_group_type == :bit_level_file_groups
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
  resources :access_systems
  resources :package_profiles
  resources :directories, :only => :show
  resources :files, :only => :show, :controller => "bit_files" do
    member do
      get 'contents'
      get 'view_fits_xml'
      get 'create_fits_xml'
    end
  end
  resources :virus_scans, :only => :show
  resources :scheduled_events, only: [:edit, :update, :create, :destroy] do
    member do
      post 'complete'
      post 'cancel'
    end
  end

  resources :cfs_files, :only => :show do
    member do
      get 'create_fits_xml'
      get 'fits_xml'
      get 'download'
      get 'view'
      get 'preview_image'
    end
  end
  resources :cfs_directories, :only => :show do
    member do
      post 'create_fits_for_tree'
      post 'export'
      post 'export_tree'
    end
  end

  resources :searches, :only => [] do
    collection do
      post :filename
    end
  end

  match '/auth/:provider/callback', to: 'sessions#create', :via => [:get, :post]
  match '/login', to: 'sessions#new', as: :login, :via => [:get, :post]
  match '/logout', to: 'sessions#destroy', as: :logout, :via => [:get, :post]
  match '/unauthorized', to: 'sessions#unauthorized', as: :unauthorized, :via => [:get, :post]
  match '/unauthorized_net_id', to: 'sessions#unauthorized_net_id', as: :unauthorized_net_id, :via => [:get, :post]
  match '/static/:page', to: 'static#page', as: :static, :via => [:get, :post]
  match '/dashboard', to: 'dashboard#show', as: :dashboard, :via => [:get, :post]

  namespace :book_tracker do
    resources 'items'
    resources 'tasks', only: 'index'
    match 'statistics', to: 'statistics#index', via: 'get'

    match 'check-hathitrust', to: 'tasks#check_hathitrust', via: 'post',
          as: 'check_hathitrust'
    match 'check-internet-archive', to: 'tasks#check_internet_archive',
          via: 'post', as: 'check_internet_archive'
    match 'import', to: 'tasks#import', via: 'post'
  end

end
