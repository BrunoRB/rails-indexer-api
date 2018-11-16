Rails.application.routes.draw do
  jsonapi_resources :pages
  jsonapi_resources :indexeds

  root 'indexeds#index'
end
