FactoryBot.define do
  factory :course_event_indicator do
    course_uuid                 { SecureRandom.uuid.to_s }
    course_last_bundled_seqnum  { -1 }
    course_needs_attention      { false }
    course_waiting_since        { Time.current }
  end
end
