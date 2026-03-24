Rails.application.routes.draw do
  devise_for :users, skip: :all
  post "/graphql", to: "graphql#execute"

  namespace :api do
    get "analytics/database-insights-overview", to: "analytics#database_insights_overview"
    get "analytics/database-insights-distributions", to: "analytics#database_insights_distributions"
    get "analytics/team", to: "analytics#team"

    get "users/:id", to: "users#show"
    post "users/accmgr", to: "users#create_account_manager"
    post "users/login", to: "users#login"
    post "users/logout", to: "users#logout"

    post "investors/search", to: "investors#search"
    post "investors/export-by-filters", to: "investors#export_by_filters"
    post "investors/export-by-ids", to: "investors#export_by_ids"
    post "investors", to: "investors#create"
    get "investors/:id", to: "investors#show"
    patch "investors/:id", to: "investors#update"
    patch "investors/qualify/:id", to: "investors#qualify"

    get "investment-vehicles/:id", to: "investment_vehicles#show"
    post "investment-vehicles", to: "investment_vehicles#create"
    patch "investment-vehicles/:id", to: "investment_vehicles#update"

    get "investment-strategies/:id", to: "investment_strategies#show"
    post "investment-strategies", to: "investment_strategies#create"
    patch "investment-strategies/:id", to: "investment_strategies#update"

    get "investor-contacts/:investor_id", to: "investor_contacts#index"
    post "investor-contacts", to: "investor_contacts#create"
    patch "investor-contacts/:id", to: "investor_contacts#update"
    delete "investor-contacts/:id", to: "investor_contacts#destroy"

    get "investment-entities/:investor_id", to: "investment_entities#index"
    post "investment-entities", to: "investment_entities#create"
    patch "investment-entities/:id", to: "investment_entities#update"
    delete "investment-entities/:id", to: "investment_entities#destroy"

    get "regions", to: "regions#index"
    get "countries", to: "countries#index"
    get "cities/country/:id", to: "cities#by_country"
    get "organizations", to: "organizations#index"
    get "ideal-investor-profiles", to: "ideal_investor_profiles#index"
    get "proof-ledger", to: "proof_ledger#index"
    get "proof-ledger/comments", to: "proof_ledger#comments"
    post "proof-ledger/comments", to: "proof_ledger#create_comment"
  end
end
