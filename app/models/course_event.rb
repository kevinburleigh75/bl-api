class CourseEvent < ApplicationRecord
  extend Enumerize

  enumerize :event_type, in: [
    :create_course,
    :prepare_course_ecosystem,
    :update_course_ecosystem,
    :update_roster,
    :update_course_active_dates,
    :update_globally_excluded_exercises,
    :update_course_excluded_exercises,
    :create_update_assignment,
    :record_response,
  ]

  # enum type: {
  #   no_op:                              -1,
  #   create_course:                       0,
  #   prepare_course_ecosystem:            1,
  #   update_course_ecosystem:             2,
  #   update_roster:                       3,
  #   update_course_active_dates:          4,
  #   update_globally_excluded_exercises:  5,
  #   update_course_excluded_exercises:    6,
  #   create_update_assignment:            7,
  #   record_response:                     8,
  # }

  # validates :type,            presence: true
  # validates :course_uuid,     presence: true
  # validates :sequence_number, presence: true,
  #                             uniqueness: { scope: :course_uuid },
  #                             numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :course_seqnum, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
