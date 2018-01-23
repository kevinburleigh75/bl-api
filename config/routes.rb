Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/record_responses' => 'external/responses#record'
  post '/create_course' => 'external/courses#create'
  post '/update_course_active_dates' => 'external/courses#update_active_dates'
end
