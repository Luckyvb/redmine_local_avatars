# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :my, only: [] do
  get :avatar_edit, on: :collection
end

resources :users, only: [] do
  get 'avatar_destroy',
      to: 'avatar#destroy'
  get 'avatar',
      to: 'avatar#show'
  post 'avatar',
       to: 'avatar#update'
  post 'avatar/upload.:format', to: 'avatar#upload', as: 'avatar_upload'
end

resources :groups, only: [] do
  get 'avatar_destroy',
      to: 'avatar#destroy'
  get 'avatar',
      to: 'avatar#show'
  post 'avatar',
       to: 'avatar#update'
  post 'avatar/upload.:format', to: 'avatar#upload', as: 'avatar_upload'
end
