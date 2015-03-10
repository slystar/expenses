Expenses::Application.routes.draw do
    # ImportHistory
    get "import_histories/:id" => "import_histories#show"
    get "import_histories" => "import_histories#index"

    get "payment_notes/create"

    # Default
    root :to => 'expenses#menu'

    # User
    get "logout" => "sessions#destroy", :as => "logout"
    get "login" => "sessions#new", :as => "login"
    get "signup" => "users#new", :as => "signup"
    resources :users
    resources :sessions
    resources :groups

    # Expenses
    get "menu" => "expenses#menu", :as => 'menu'
    get "expenses/import" => "expenses#import", :as => 'import'
    get "expenses/process_imports" => "expenses#process_imports", :as => 'process_imports'
    get "expenses/process_data" => "expenses#process_data", :as => 'process_data'
    match 'expenses/process_import/:id' => 'expenses#process_import'
    post "expenses/import" => "expenses#file_upload"
    post "expenses/add_imported_expenses" => "expenses#add_imported_expenses"
    post "expenses/create_from_imported" => "expenses#create_from_imported"
    post "expenses/process_all_now" => "expenses#process_all_now"
    delete "expenses/delete_imported_records" => "expenses#delete_imported_records"

    # UserPayemtns
    get "user_payments/approve" => "user_payments#approve"
    post "user_payments/approve_payment" => "user_payments#approve_payment"

    # PaymentNotes
    post "user_payments/add_note" => "user_payments#add_note"
    delete "user_payments/remove_note" => "user_payments#remove_note"

    # Stores
    get "stores/parents"
    post "stores/save_parents"


    # Generated resources
    resources :expenses
    resources :user_payments
    resources :pay_methods
    resources :reasons
    resources :stores

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
    # match ':controller(/:action(/:id(.:format)))'
end
