InvtappServer::Application.routes.draw do
  resources :notifications

  resources :public_events

  resources :cities do
    get :get_cities, :on => :collection
  end

  resources :services do
    get :get_services, :on => :collection
  end

  resources :chat_rooms do
    get :get_chats, :on => :collection
    get :post_inter_chat_message, :on => :collection
    get :get_inter_chat_messages, :on => :collection
  end

  resources :currencies do
    get :my_notifications, :on => :collection
    get :clear_notifications, :on => :collection
  end

  resources :groups do
    get :create_group, :on => :collection
    get :get_my_groups, :on => :collection
    get :differentiate_contacts, :on => :collection
    get :create_group_by_invites, :on => :collection
    get :group_members_list,:on => :collection
    get :event_admins,:on => :collection
    get :get_group_members,:on => :collection
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
    get :invitees_locations, :on => :collection
    get :invitees_distances, :on => :collection
    get :get_all_events_information, :on => :collection
    get :make_invite_as_admin_to_event, :on => :collection
    get :delete_admins_form_events, :on => :collection
    get :block_invitations, :on => :collection
    get :check_contacts, :on => :collection
  end

  resources :users do
    get :log_in_with_mobile, :on => :collection
    get :register_with_mobile, :on => :collection
    get :home_page, :on => :collection
    get :get_user_details, :on => :collection
    post :update_user_details,:on => :collection
    get :store_gcm_code, :on => :collection
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
