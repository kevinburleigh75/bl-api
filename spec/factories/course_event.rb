FactoryBot.define do
  factory :course_event do
    event_uuid         { SecureRandom.uuid }
    event_type         { CourseEvent.event_type.values.sample }
    course_uuid        { SecureRandom.uuid }
    course_seqnum      { (CourseEvent.where(course_uuid: course_uuid).maximum(:course_seqnum) || -1) + 1 }
    has_been_processed { [true, false].sample }
    data               { {} }
  end
end
