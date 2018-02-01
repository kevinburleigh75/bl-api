require 'rails_helper'

RSpec.describe Services::UpdateCourseExerciseExclusions::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(exclusions: given_exclusion_data) }

  let(:given_course_events) {
    [
      CourseEvent.new(
        event_uuid:             given_exclusion_data.fetch(:request_uuid),
        event_type:             CourseEvent.event_type.update_course_exercise_exclusions,
        course_uuid:            given_exclusion_data.fetch(:course_uuid),
        course_seqnum:          given_exclusion_data.fetch(:sequence_number),
        event_has_been_bundled: false,
        event_data: given_exclusion_data.slice(
          :request_uuid,
          :exclusions,
        ),
      )
    ]
  }

  let(:process_payload) { {course_events: given_course_events} }
  let(:process_result)  { given_course_events.map{|event| event.event_uuid} }

  let(:target_result) { {status: 'success'} }

  let(:service_double) {
    object_double(Utils::RecordCourseEvents::Util.new).tap do |dbl|
      allow(dbl).to receive(:process).and_return(process_result)
    end
  }

  before(:each) do
    allow(Utils::RecordCourseEvents::Util).to receive(:new).and_return(service_double)
  end

  context "when valid exclusion data is given" do
    let(:given_exclusion_data) {
      {
        request_uuid:    SecureRandom.uuid.to_s,
        course_uuid:     SecureRandom.uuid.to_s,
        sequence_number: Kernel.rand(10),
        exclusions:      [
          { exercise_uuid:       SecureRandom.uuid.to_s},
          { exercise_group_uuid: SecureRandom.uuid.to_s},
        ],
        updated_at:      Time.current.iso8601(6),
      }
    }

    it "the RecordCourseEvents service is called with the correct CourseEvents" do
      action
      expect(service_double).to have_received(:process).with(the_same_records_as(process_payload))
    end

    it "the correct result is returned" do
      expect(action).to eq(target_result)
    end
  end
end
