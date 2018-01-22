FactoryBot.define do
  factory :course_event_indicator do
    course_uuid        { SecureRandom.uuid.to_s }
    last_course_seqnum { -1 }
    needs_attention    { false }
    waiting_since      { Time.current }
  end
end
