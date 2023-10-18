Rails.application.routes.draw do
  resources :locations do
    collection do
      get :find
    end
  end
end
