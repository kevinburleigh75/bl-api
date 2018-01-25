require 'rails_helper'

RSpec.describe Services::CreateCourse::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(course_info: given_course_info) }

  let(:given_course_info) {
    {
      course_uuid:    SecureRandom.uuid.to_s,
      ecosystem_uuid: SecureRandom.uuid.to_s,
      is_real_course: [ true, false ].sample,
      starts_at:      Time.current.iso8601(6),
      ends_at:        Time.current.tomorrow.iso8601(6),
      created_at:     Time.current.yesterday.iso8601(6),
    }
  }

  let(:given_course_event) {
    CourseEvent.new(
      event_uuid:             given_course_info.fetch(:course_uuid),
      event_type:             CourseEvent.event_type.create_course,
      course_uuid:            given_course_info.fetch(:course_uuid),
      course_seqnum:          0,
      event_has_been_bundled: false,
      event_data: given_course_info.slice(
        :course_uuid,
        :sequence_number,
        :ecosystem_uuid,
        :is_real_course,
        :starts_at,
        :ends_at,
        :created_at,
      ),
    )
  }

  let(:process_payload) { {course_events: [given_course_event]} }
  let(:process_result)  { [given_course_event.event_uuid] }

  let(:service_double) {
    object_double(Services::RecordCourseEvents::Service.new).tap do |dbl|
      allow(dbl).to receive(:process).and_return(process_result)
    end
  }

  before(:each) do
    allow(Services::RecordCourseEvents::Service).to receive(:new).and_return(service_double)
  end

  it "the RecordCourseEvents service is called with the correct CourseEvents" do
    action
    expect(service_double).to have_received(:process).with(the_same_records_as(process_payload))
  end

  it "the uuid returned from the RecordCourseEvents service is properly returned" do
    expect(action.fetch(:created_course_uuid)).to eq(given_course_info.fetch(:course_uuid))
  end

end