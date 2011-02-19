Rails.application.routes.draw do
  scope Interpret.scope do
    namespace :interpret do
      resources :translations, :only => [:edit, :update] do
        resources :translations, :only => [:new, :create]
      end

      resources :tools, :only => :index do
        collection do
          get :export
          post :import
          post :dump
          post :run_update
        end
      end

      match "search", :to => "search#index"
      match "search_for", :to => "search#perform"

      root :to => "translations#index"
    end
  end
end
