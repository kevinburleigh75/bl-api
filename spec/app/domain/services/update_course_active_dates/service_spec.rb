require 'rails_helper'

RSpec::Matchers.define :the_same_records_as do |expected|
  match do |actual|
    ## same keys
    result = expected.keys.sort == actual.keys.sort
    break result unless result

    ## for each key
    result = expected.keys.each do |key|
      ## same number of values
      expected_records = expected[key]
      actual_records   = actual[key]
      break false if expected_records.count != actual_records.count

      ## same values (order doesn't matter)
      result = Array(expected_records).each do |expected_record|
        break false unless Array(actual_records).detect{|actual_record| actual_record.attributes == expected_record.attributes}
        true
      end
      break result unless result
    end
    result
  end
end

RSpec.describe Services::UpdateCourseActiveDates::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(course_info: given_course_info) }

  let(:given_course_info) {
    {
      request_uuid:    SecureRandom.uuid.to_s,
      course_uuid:     SecureRandom.uuid.to_s,
      sequence_number: Kernel.rand(1000),
      starts_at:       Time.current.iso8601(6),
      ends_at:         Time.current.tomorrow.iso8601(6),
      updated_at:      Time.current.yesterday.iso8601(6),
    }
  }

  let(:given_course_event) {
    CourseEvent.new(
      event_uuid:         given_course_info.fetch(:request_uuid),
      event_type:         CourseEvent.event_type.update_course_active_dates,
      course_uuid:        given_course_info.fetch(:course_uuid),
      course_seqnum:      given_course_info.fetch(:sequence_number),
      has_been_processed: false,
      data: given_course_info.slice(
        :request_uuid,
        :course_uuid,
        :sequence_number,
        :starts_at,
        :ends_at,
        :updated_at,
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
    expect(action.fetch(:updated_course_uuid)).to eq(given_course_info.fetch(:request_uuid))
  end
end
