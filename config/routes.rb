Rails.application.routes.draw do
  get 'home/index'


  root 'design_templates#index'

  get 'edit' => 'home#edit'

  get '/partials/version_settings/:id' => 'partials#version_settings'
  get '/partials/extracted_settings/:id' => 'partials#extracted_settings'


  get '/versions/create' => 'versions#create'
  get '/versions/:id/update' => 'versions#update'


  post '/design_templates/create' => 'design_templates#create'
  get '/design_templates/:id/edit' => 'design_templates#edit'
  get '/design_templates/:id/update' => 'design_templates#update'
  get '/design_templates/edit' => 'design_templates#edit'
  post '/design_templates/:id/update' => 'design_templates#update'



  post '/design_templates/:id/tag_settings' => 'design_templates#set_tag_settings'
  get 'force_process' => 'design_templates#force_process'


  resources :design_templates
  resources :versions



  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
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
