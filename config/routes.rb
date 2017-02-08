InvtappServer::Application.routes.draw do
  resources :groups do
    get :create_group, :on => :collection
    get :get_my_groups, :on => :collection
    get :differentiate_contacts, :on => :collection
    get :create_group_by_invites, :on => :collection
  end

  resources :events do
    post :create_event, :on => :collection
    post :create_invitations, :on => :collection
    post :create_new_invitations, :on => :collection
    get :get_my_invitations, :on => :collection
    get :get_my_events, :on => :collection
    post :post_location, :on => :collection
    get :get_participants_locations, :on => :collection
    get :accept_or_reject_invitation, :on => :collection
    get :event_invitations, :on => :collection
    get :user_locations, :on => :collection
    get :event_user_locations, :on => :collection
    get :get_distance_from_event, :on => :collection
    get :invitee_check_in_Status, :on => :collection
    get :delete_event, :on => :collection
    get :get_all_events, :on => :collection
  end

  resources :users do
    get :create_user, :on => :collection
    get :login, :on => :collection
    get :home_page, :on => :collection
  end


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
  root :to => 'users#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
