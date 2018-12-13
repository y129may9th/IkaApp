Rails.application.routes.draw do
  post '/callback' => 'ikabot#callback'
end
