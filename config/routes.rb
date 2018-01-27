Rails.application.routes.draw do
  get 'main/index'
  get 'refresh_table', to: 'main#refresh_table'
  get 'add/:shortName', to: 'main#addFavourite'
  get 'add', to: 'main#addFavourite'
  get 'del/:shortName/:backStop', to: 'main#delFavourite'
  get 'del/:shortName', to: 'main#delFavourite'
  get 'del', to: 'main#delFavourite'
  get 'change', to: 'main#changeMaxSize'
  root 'main#index'

  get 'admin', to: 'admin_panel#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
