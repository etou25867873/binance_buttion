Rails.application.routes.draw do
  root "escape#index"
  get  "escape/read"  => "escape#read"
  get  "escape/withdraw"  => "escape#withdraw"
end
