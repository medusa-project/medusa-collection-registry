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
  resources :assessments, only: [:show, :edit, :update, :new, :create, :destroy]
  resources :attachments, only: [:show, :edit, :update, :new, :create, :destroy] do
    member do
      get 'download'
    end
  end
  resources :events do
    collection do
      get :autocomplete_user_uid
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
    end
  end
  resources :cfs_directories, :only => :show do
    member do
      post 'create_fits_for_tree'
    end
  end

  match '/auth/:provider/callback', to: 'sessions#create', :via => [:get, :post]
  match '/login', to: 'sessions#new', as: :login, :via => [:get, :post]
  match '/logout', to: 'sessions#destroy', as: :logout, :via => [:get, :post]
  match '/unauthorized', to: 'sessions#unauthorized', as: :unauthorized, :via => [:get, :post]
  match '/unauthorized_net_id', to: 'sessions#unauthorized_net_id', as: :unauthorized_net_id, :via => [:get, :post]
  match '/static/:page', to: 'static#page', as: :static, :via => [:get, :post]
  match '/dashboard', to: 'dashboard#show', as: :dashboard, :via => [:get, :post]

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

end
