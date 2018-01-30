Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/record_responses'           => 'external/responses#record'
  post '/create_course'              => 'external/courses#create'
  post '/create_ecosystem'           => 'external/ecosystems#create'
  post '/create_update_assignments'  => 'external/assignments#create_update'
  post '/update_course_active_dates' => 'external/courses#update_active_dates'
  post '/fetch_student_clues'        => 'external/clues#fetch_student'
  post '/fetch_teacher_clues'        => 'external/clues#fetch_teacher'
end
