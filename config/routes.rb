MedusaRails3::Application.routes.draw do

  get "events/index"

  get "ingest_statuses/update"

  root :to => 'static#page', :page => 'landing'

  resources :collections
  resources :repositories
  resources :assessments
  resources :file_groups do
    member do
      post 'create_all_fits'
      post 'create_cfs_fits'
      get 'events'
      post 'new_event'
      post 'create_virus_scan'
    end
  end
  resources :producers
  resources :access_systems
  resources :ingest_statuses
  resources :directories, :only => :show
  resources :files, :only => :show, :controller => "bit_files" do
    member do
      get 'contents'
      get 'view_fits_xml'
      get 'create_fits_xml'
    end
  end

  #cfs (i.e. server local filesystem)
  get '/cfs/show/*path' => 'cfs#show', format: false, as: :cfs_show
  get '/cfs/show' => 'cfs#show', format: false
  get '/cfs/fits_info/*path' => 'cfs#fits_info', format: false, as: :cfs_fits_info
  match '/cfs/create_fits_info/*path' => 'cfs#create_fits_info', format: false, as: :cfs_create_fits_info
  match '/cfs/create_fits_for_tree/*path' => 'cfs#create_fits_for_tree', format: false, as: :cfs_create_fits_for_tree
  match '/cfs/create_fits_for_tree' => 'cfs#create_fits_for_tree', format: false

  match '/auth/:provider/callback', to: 'sessions#create'
  match '/login', to: 'sessions#new', as: :login
  match '/logout', to: 'sessions#destroy', as: :logout
  match '/unauthorized', to: 'sessions#unauthorized', as: :unauthorized
  match '/static/:page', to: 'static#page', as: :static
  match '/dashboard', to: 'dashboard#show', as: :dashboard

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
