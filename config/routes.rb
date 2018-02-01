Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/create_course'              => 'external/courses#create'
  post '/update_course_active_dates' => 'external/courses#update_active_dates'

  post '/create_ecosystem'           => 'external/ecosystems#create'

  post '/update_course_exercise_exclusions' => 'external/exercise_exclusions#update_course'
  post '/update_global_exercise_exclusions' => 'external/exercise_exclusions#update_global'

  post '/create_update_assignments'  => 'external/assignments#create_update'

  post '/fetch_student_clues'        => 'external/clues#fetch_student'
  post '/fetch_teacher_clues'        => 'external/clues#fetch_teacher'

  post '/prepare_course_ecosystem'   => 'external/course_ecosystems#prepare'
  post '/update_course_ecosystem'    => 'external/course_ecosystems#update'

  post '/record_responses'           => 'external/responses#record'

  post '/update_rosters'             => 'external/rosters#update'
end
