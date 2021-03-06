Rails.application.routes.draw do
  get 'home/index'

  root 'design_templates#index'

  get '/tools' => 'home#tools'
  get '/trans_butt' => 'home#trans_butt'
  get '/trans_butt_settings' => 'home#trans_butt_settings'
  get '/update_users' => 'home#update_users'
  get '/log_in/' => 'home#log_in'
  get '/process_log_in/' => 'home#process_log_in'
  get '/log_out/' => 'home#log_out'

  get '/do_process_version' => 'remote#do_process_version'
  get '/do_extract_tags' => 'remote#do_extract_tags'
  get '/do_extract_images' => 'remote#do_extract_images'

  get '/colors/:id/update' => 'colors#update'
  get '/colors/delete_all' => 'colors#delete_all'

  get '/managed_assets/:id/update' => 'managed_assets#update'
  get '/managed_assets/delete_all' => 'managed_assets#delete_all'

  get '/palettes/:id/update' => 'palettes#update'
  get '/palettes/:id/add' => 'palettes#add'
  get '/palettes/:id/remove' => 'palettes#remove'
  get '/palettes/:id/remove_all' => 'palettes#remove_all'
  get '/palettes/delete_all' => 'palettes#delete_all'

  get '/partials/version_settings' => 'partials#version_settings'
  get '/partials/extracted_settings/:id' => 'partials#design_template_settings'
  get '/partials/quick_new' => 'partials#quick_new'
  get '/partials/_version_managed_assets' => 'partials#_version_managed_assets'
  get '/partials/_design_template_managed_assets' => 'partials#_design_template_managed_assets'


  get '/versions/create' => 'versions#create'
  get '/versions/:id/update' => 'versions#update'
  post '/versions/create' => 'versions#create'
  post '/versions/:id/update' => 'versions#update'
  get '/versions/delete_all' => 'versions#delete_all'
  get '/versions/:id/cancel' => 'versions#cancel'
  get '/versions/quick_new' => 'versions#quick_new'
  get '/versions/:id/update_render_folder' => 'versions#update_render_folder'

  post '/design_templates/create' => 'design_templates#create'
  get '/design_templates/:id/edit' => 'design_templates#edit'
  get '/design_templates/:id/update' => 'design_templates#update'
  get '/design_templates/edit' => 'design_templates#edit'
  post '/design_templates/:id/update' => 'design_templates#update'
  post '/design_templates/:id/settings' => 'design_templates#all_settings'
  post '/design_templates/:id/add_asset' => 'design_templates#add_asset'
  get '/design_templates/delete_all' => 'design_templates#delete_all'
  get '/design_templates/make_zombie' => 'design_templates#make_zombie'
  get '/design_templates/:id/remove_all_managed_assets' => 'design_templates#remove_all_managed_assets'
  get '/design_templates/:id/remove_managed_asset' => 'design_templates#remove_managed_asset'
  get '/design_templates/:id/add_managed_asset' => 'design_templates#add_managed_asset'
  get '/design_templates/:id/move_asset_up' => 'design_templates#move_asset_up'
  get '/design_templates/:id/move_asset_down' => 'design_templates#move_asset_down'


  get 'force_process' => 'design_templates#force_process'

  post '/replacement_images/create' => 'replacement_images#create'
  post '/replacement_images/' => 'replacement_images#create'

  resources :design_templates
  resources :versions
  resources :colors
  resources :palettes
  resources :replacement_images
  resources :managed_assets
  resources :users




  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with 'rake routes'.

  # You can have the root of your site routed with 'root'
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
