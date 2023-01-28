Rails.application.routes.draw do
  root "escape#index"
  get  "escape/show"  => "escape#show"
  get  "escape/withdraw"  => "escape#withdraw"
end
