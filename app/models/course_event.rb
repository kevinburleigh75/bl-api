class CourseEvent < ApplicationRecord
  extend Enumerize

  enumerize :event_type, in: [
    :create_course,
    :prepare_course_ecosystem,
    :update_course_ecosystem,
    :update_roster,
    :update_course_active_dates,
    :update_global_exercise_exclusions,
    :update_course_exercise_exclusions,
    :create_update_assignment,
    :record_response,
  ]

  validates :course_seqnum, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
