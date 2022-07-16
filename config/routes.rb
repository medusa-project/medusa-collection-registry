Rails.application.routes.draw do

  resources :static_pages, only: [:show, :edit, :update], param: :key do
    member do
      post :deposit_files
      post :feedback
      post :request_training
    end
  end
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/login', to: 'sessions#new', as: :login, via: [:get, :post]
  match '/logout', to: 'sessions#destroy', as: :logout, via: [:get, :post]
  match '/unauthorized', to: 'sessions#unauthorized', as: :unauthorized, via: [:get, :post]
  match '/unauthorized_net_id', to: 'sessions#unauthorized_net_id', as: :unauthorized_net_id, via: [:get, :post]

  #This lets us start up in a mode where only a down page is shown
  if ENV['MEDUSA_DOWN'] == 'true'
    match '*path' => redirect('/static_pages/down', status: 307), via: :all
    root to: 'static_pages#show', key: 'down'
  else
    root to: 'static_pages#show', key: 'landing'
  end

  concern :eventable, Proc.new {member {get 'events'}}
  concern :red_flaggable, Proc.new {member {get 'red_flags'}}
  concern :assessable, Proc.new {member {get 'assessments'}}
  concern :attachable, Proc.new {member {get 'attachments'}}
  concern :downloadable, Proc.new {member {get 'download'}}
  concern :collection_indexer, Proc.new {member {get 'collections'}}
  concern :gallery_viewer, Proc.new {member {post 'toggle_gallery_viewer'}}
  concern :autocomplete_email, Proc.new {collection {get :autocomplete_user_email}}

  resources :collections, concerns: %i(eventable red_flaggable assessable attachable) do
    get :show_file_stats, on: :member
    get :view_in_dls, on: :member
    get :timeline, on: :member
  end

  resources :repositories, concerns: %i(eventable red_flaggable assessable collection_indexer) do
    get :edit_ldap_admins, on: :collection
    get :timeline, on: :member
    put :update_ldap_admin, on: :member
    %i(show_file_stats show_running_processes show_red_flags show_events show_accruals).each do |action|
      get action, on: :member
    end
  end
  resources :virtual_repositories do
    get :show_file_stats, on: :member
  end
  resources :institutions
  resources :assessments, only: [:show, :edit, :update, :new, :create, :destroy]
  resources :attachments, only: [:show, :edit, :update, :new, :create, :destroy], concerns: :downloadable

  resources :events, concerns: :autocomplete_email do
    get :report, on: :collection
    post :report, on: :collection
    get :filter, on: :collection
    post :download_csv, on: :collection
  end

  [:file_groups, :external_file_groups, :bit_level_file_groups].each do |file_group_type|
    resources file_group_type, only: [:show, :edit, :update, :new, :create, :destroy],
              concerns: %i(eventable red_flaggable assessable attachable) do
      post :create_initial_cfs_assessment, on: :member if file_group_type == :bit_level_file_groups
      get :timeline, on: :member if file_group_type == :bit_level_file_groups
      if file_group_type == :external_file_groups
        post :create_bit_level, on: :member
      end
      get :content_type_manifest, on: :member
      get :new_event, on: :member
    end
  end

  resources :red_flags, only: [:show, :edit, :update] do
    post :unflag, on: :member
    post :mass_unflag, on: :collection
  end

  resources :projects, concerns: [:attachable, :autocomplete_email] do
    post :mass_action, on: :member
    get :start_items_upload, on: :member
    post :upload_items, on: :member
    get :items, on: :member
    get :public_show, on: :member
    get :ingest_path_info, on: :collection
  end
  resources :items do
    get :barcode_lookup, on: :collection
  end
  resources :producers do
    get :report, on: :member
  end
  resources :access_systems, concerns: :collection_indexer

  resources :cfs_files, only: :show, concerns: %i(downloadable eventable) do
    %i(fits view preview_pdf preview_content thumbnail).each {|action| get action, on: :member}
    get :random, on: :collection
  end
  get 'cfs_files/:id/preview_iiif_image/*iiif_parameters', to: 'cfs_files#preview_iiif_image', as: 'preview_iiif_image_cfs_file'

  resources :cfs_directories, only: :show, concerns: %i(eventable gallery_viewer) do
    %i(export export_tree).each {|action| post action, on: :member}
    get :show_tree, on: :member
    get :cfs_files, on: :member
    get :cfs_directories, on: :member
    get :report_map, on: :member
    get :report_manifest, on: :member
    get :timeline, on: :member
    post :create_initial_cfs_assessment, on: :member
  end
  resources :content_types, only: [] do
    get :cfs_files, on: :member
    get :random_cfs_file, on: :member
  end
  resources :file_extensions, only: [] do
    get :cfs_files, on: :member
    get :random_cfs_file, on: :member
    post :download_batch, on: :member
  end
  resources :file_formats do
    resources :file_format_notes, shallow: true, as: :notes
    resources :file_format_normalization_paths, shallow: true, as: :normalization_paths
    resources :pronoms, shallow: true
  end
  resources :file_format_profiles do
    post :clone, on: :member
  end
  resources :file_format_tests, only: %i(new create edit update index) do
    post :new_reason, on: :collection
  end
  resources :searches, only: [] do
    post :search, on: :collection
    get :search, on: :collection
    %i(cfs_file cfs_directory item file_group collection medusa_uuid).each do |action|
      get action, on: :collection
    end
  end
  resources :accruals, only: [] do
    get :update_display, on: :member
    post :submit, on: :collection
  end
  resources :uuids, only: [:show]

  match '/dashboard', to: 'dashboard#show', as: :dashboard, via: [:get, :post]
  %w(running_processes file_stats red_flags events accruals file_group_deletions).each do |action|
    match "/dashboard/#{action}", to: "dashboard##{action}", as: :"#{action}_dashboard", via: :get
  end

  match '/timeline', to: 'timeline#show', as: :timeline, via: :get

  resources :identities

  namespace :workflow do
    resources 'accrual_jobs', only: [] do
      post :proceed, on: :member
      get :proceed_form, on: :member
      post :abort, on: :member
      get :abort_form, on: :member
      get :view_report, on: :member
    end
    resources 'file_group_deletes', only: [:new, :create] do
      get :admin_decide, on: :member
      post :admin_record_decision, on: :member
      post :restore_content, on: :member
    end
  end
  resources :archived_accrual_jobs, only: [:show, :index]
  resources :resource_types, only: :index

  match '*unmatched', to: 'application#route_not_found', via: :all
end